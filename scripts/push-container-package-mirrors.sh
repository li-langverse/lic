#!/usr/bin/env bash
# Push container split packages to GitLab (primary) and GitHub (mirror).
# WP-CTN-070..074 — usage from lic repo root:
#   ./scripts/push-container-package-mirrors.sh [--create] [--dry-run] [--gitlab-only] [--github-only]
# Requires: GITLAB_TOKEN for GitLab; gh + GH_TOKEN for GitHub mirror.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GITLAB_HOST="${GITLAB_HOST:-gitlab.lilangverse.xyz}"
GITLAB_GROUP="${GITLAB_GROUP:-li-langverse}"
GITHUB_ORG="${LI_ORG:-li-langverse}"
PACKAGES=(li-oci li-container li-container-run)

CREATE=0
DRY=0
GITLAB_ONLY=0
GITHUB_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --create) CREATE=1 ;;
    --dry-run) DRY=1 ;;
    --gitlab-only) GITLAB_ONLY=1 ;;
    --github-only) GITHUB_ONLY=1 ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

sync_tree() {
  local src="$1" dst="$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude='.git' "$src/" "$dst/"
  else
    rm -rf "$dst"/*
    cp -a "$src/." "$dst/"
  fi
}

gitlab_api() {
  local method="${1:-GET}"
  local path="$2"
  local body="${3:-}"
  local args=(-sS -X "$method"
    -H "PRIVATE-TOKEN: ${GITLAB_TOKEN:?GITLAB_TOKEN required for GitLab push}"
    -H "Content-Type: application/json")
  if [[ -n "$body" ]]; then
    args+=(-d "$body")
  fi
  curl "${args[@]}" "https://${GITLAB_HOST}/api/v4${path}"
}

gitlab_group_id() {
  gitlab_api GET "/groups/${GITLAB_GROUP}" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])"
}

ensure_gitlab_project() {
  local name="$1"
  local path_enc="${GITLAB_GROUP}%2F${name}"
  local code
  code="$(curl -s -o /dev/null -w '%{http_code}' \
    -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "https://${GITLAB_HOST}/api/v4/projects/${path_enc}")"
  if [[ "$code" == "200" ]]; then
    return 0
  fi
  if [[ "$CREATE" -ne 1 ]]; then
    echo "error: GitLab project ${GITLAB_GROUP}/${name} missing; re-run with --create" >&2
    exit 1
  fi
  local gid desc
  gid="$(gitlab_group_id)"
  desc="$(grep -E '^description\s*=' "$ROOT/packages/$name/li.toml" | head -1 \
    | sed -E 's/^description\s*=\s*"([^"]*)".*/\1/' || echo "Li package ${name}")"
  echo "==> creating GitLab project ${GITLAB_GROUP}/${name}"
  if [[ "$DRY" -eq 1 ]]; then
    echo "dry-run: would POST /projects name=$name namespace_id=$gid"
    return 0
  fi
  local body
  body="$(python3 -c "import json; print(json.dumps({'name': '$name', 'path': '$name', 'namespace_id': $gid, 'visibility': 'public', 'description': '''$desc'''}))")"
  gitlab_api POST "/projects" "$body" >/dev/null
}

push_gitlab() {
  local name="$1"
  local pkg="$ROOT/packages/$name"
  local url="https://gitlab-ci-token:${GITLAB_TOKEN}@${GITLAB_HOST}/${GITLAB_GROUP}/${name}.git"

  if [[ "$DRY" -eq 1 ]]; then
    echo "dry-run: would push $pkg -> https://${GITLAB_HOST}/${GITLAB_GROUP}/${name}"
    return 0
  fi

  ensure_gitlab_project "$name"
  (
    local tmp
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    if git ls-remote "$url" HEAD >/dev/null 2>&1; then
      git clone --depth 1 "$url" "$tmp/repo" -q
      sync_tree "$pkg" "$tmp/repo"
      cd "$tmp/repo"
      git add -A
      if git diff --cached --quiet; then
        echo "gitlab ${name}: no changes"
        exit 0
      fi
      git -c user.name="li-langverse-bot" -c user.email="bot@users.noreply.github.com" \
        commit -m "chore: sync from lic monorepo packages/${name}"
      git push origin HEAD:main
    else
      mkdir -p "$tmp/repo"
      sync_tree "$pkg" "$tmp/repo"
      cd "$tmp/repo"
      git init -q -b main
      git add -A
      git -c user.name="li-langverse-bot" -c user.email="bot@users.noreply.github.com" \
        commit -q -m "chore: initial sync from lic monorepo packages/${name}"
      git remote add origin "$url"
      git push -u origin main
    fi
  )
  echo "gitlab push-container-package-mirrors: ok — ${GITLAB_GROUP}/${name}"
}

push_github() {
  local name="$1"
  local args=(--create)
  if [[ "$DRY" -eq 1 ]]; then
    args=(--dry-run)
  elif [[ "$CREATE" -ne 1 ]]; then
    args=()
  fi
  "$ROOT/scripts/push-official-package-repo.sh" "$name" "${args[@]}"
}

for name in "${PACKAGES[@]}"; do
  if [[ ! -d "$ROOT/packages/$name" ]]; then
    echo "error: missing packages/$name" >&2
    exit 1
  fi
  if [[ "$GITHUB_ONLY" -eq 0 ]]; then
    push_gitlab "$name"
  fi
  if [[ "$GITLAB_ONLY" -eq 0 ]]; then
    push_github "$name"
  fi
done

echo "push-container-package-mirrors: all packages synced"
