#!/usr/bin/env bash
# Open PRs on official package mirrors: sync sources + CI from lic/packages/<NAME>.
# Usage: ./scripts/sync-package-mirror-def-syntax-pr.sh NAME [NAME...]
# Requires: gh auth, network.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ORG="${LI_ORG:-li-langverse}"
BRANCH="cursor/sync-def-syntax-57b4"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 NAME [NAME...]" >&2
  echo "  e.g. $0 li-std-core li-std-math li-httpd li-net li-demo" >&2
  exit 1
fi

command -v gh >/dev/null || { echo "gh required" >&2; exit 1; }
sync_tree() {
  # Overlay monorepo package onto mirror; do not delete mirror-only files (e.g. LICENSE).
  local src="$1" dst="$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude='.git' "$src/" "$dst/"
  else
    cp -a "$src/." "$dst/"
  fi
}

push_repo() {
  local name="$1"
  local pkg="$ROOT/packages/$name"
  local repo="${ORG}/${name}"
  if [[ ! -d "$pkg" ]]; then
    echo "skip $name (no packages/$name)" >&2
    return 0
  fi
  if ! gh repo view "$repo" >/dev/null 2>&1; then
    echo "skip $name (no github repo $repo)" >&2
    return 0
  fi

  local tmp
  tmp="$(mktemp -d)"

  gh repo clone "$repo" "$tmp/repo" -- --depth 1 -b main
  cd "$tmp/repo"
  sync_tree "$pkg" .
  git checkout -B "$BRANCH"
  git add -A
  if git diff --cached --quiet; then
    echo "$name: no changes vs mirror"
    cd "$ROOT"
    rm -rf "$tmp"
    return 0
  fi
  git -c user.name="li-langverse-bot" -c user.email="bot@users.noreply.github.com" \
    commit -m "chore: sync def syntax + CI from lic packages/${name}"

  local remote="https://github.com/${repo}.git"
  if [[ -n "${GH_TOKEN:-}" ]]; then
    remote="https://x-access-token:${GH_TOKEN}@github.com/${repo}.git"
  elif command -v gh >/dev/null 2>&1; then
    remote="https://x-access-token:$(gh auth token)@github.com/${repo}.git"
  fi
  git push "$remote" "$BRANCH" --force-with-lease 2>/dev/null \
    || git push "$remote" "$BRANCH" --force

  local exist
  exist="$(gh pr list --repo "$repo" --head "$BRANCH" --json number -q '.[0].number' 2>/dev/null || true)"
  if [[ -n "$exist" && "$exist" != "null" ]]; then
    echo "$name: PR https://github.com/${repo}/pull/${exist}"
  else
    gh pr create --repo "$repo" --base main --head "$BRANCH" \
      --title "chore: enforce def syntax (sync from lic)" \
      --body "Sync \`packages/${name}/\` from [lic](https://github.com/li-langverse/lic) — Python-style \`def\` for procedures, \`extern proc\` only for FFI. CI runs \`check-li-def-syntax.sh\` before \`lic build\`.

Depends on https://github.com/li-langverse/lic/pull/58 (compiler rejects bare \`proc\`)."
    echo "$name: opened PR"
  fi
  cd "$ROOT"
  rm -rf "$tmp"
}

for name in "$@"; do
  push_repo "$name"
done
