#!/usr/bin/env bash
# Push packages/<name>/ to li-langverse/<name> (official package mirror).
# Usage: ./scripts/push-official-package-repo.sh NAME [--create] [--dry-run]
# Requires: GH_TOKEN or gh auth; never commit tokens.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: push-official-package-repo.sh NAME [--create] [--dry-run]}"
shift || true
CREATE=0
DRY=0
for arg in "$@"; do
  case "$arg" in
    --create) CREATE=1 ;;
    --dry-run) DRY=1 ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

PKG="$ROOT/packages/$NAME"
if [[ ! -d "$PKG" ]]; then
  echo "error: missing $PKG" >&2
  exit 1
fi

ORG="${LI_ORG:-li-langverse}"
REPO="${ORG}/${NAME}"
DESC="Li package ${NAME}"
if [[ -f "$PKG/li.toml" ]]; then
  line="$(grep -E '^description\s*=' "$PKG/li.toml" | head -1 || true)"
  if [[ -n "$line" ]]; then
    DESC="$(echo "$line" | sed -E 's/^description\s*=\s*"([^"]*)".*/\1/')"
  fi
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI required" >&2
  exit 1
fi

if [[ "$DRY" -eq 1 ]]; then
  echo "dry-run: would push $PKG -> https://github.com/$REPO (create=$CREATE)"
  exit 0
fi

if ! gh repo view "$REPO" >/dev/null 2>&1; then
  if [[ "$CREATE" -ne 1 ]]; then
    echo "error: $REPO does not exist; re-run with --create" >&2
    exit 1
  fi
  echo "==> creating $REPO"
  gh repo create "$REPO" --public --description "$DESC" \
    --license apache-2.0 --confirm
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
rsync -a --delete --exclude='.git' "$PKG/" "$TMP/"
cd "$TMP"
git init -q -b main
git add -A
if git diff --cached --quiet; then
  echo "nothing to commit for $NAME"
  exit 0
fi
git -c user.name="li-langverse-bot" -c user.email="bot@users.noreply.github.com" \
  commit -q -m "chore: sync from lic monorepo packages/${NAME}"

REMOTE="https://github.com/${REPO}.git"
if [[ -n "${GH_TOKEN:-}" ]]; then
  REMOTE="https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git"
fi
git remote add origin "$REMOTE"
if gh api "repos/${REPO}/commits/main" >/dev/null 2>&1; then
  git pull origin main --rebase || true
  git push origin main
else
  git push -u origin main
fi
echo "push-official-package-repo: ok — $REPO"
