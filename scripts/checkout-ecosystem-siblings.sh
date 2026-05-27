#!/usr/bin/env bash
# Clone li-langverse/lip and lit beside lic (CI and local smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(cd "$ROOT/.." && pwd)"
LIP_ORG="${LIP_ORG:-li-langverse/lip}"
LIT_ORG="${LIT_ORG:-li-langverse/lit}"
REF="${ECOSYSTEM_REF:-main}"

DEST_ROOT="${ECOSYSTEM_SIBLINGS_ROOT:-}"
if [[ -z "$DEST_ROOT" ]]; then
  if mkdir -p "$PARENT/.ci-sibling-write-test" 2>/dev/null \
    && rmdir "$PARENT/.ci-sibling-write-test" 2>/dev/null; then
    DEST_ROOT="$PARENT"
  else
    DEST_ROOT="$ROOT/ecosystem"
  fi
fi
mkdir -p "$DEST_ROOT"

clone_repo() {
  local slug="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" fetch --depth 1 origin "$REF"
    git -C "$dest" checkout -q "$REF"
    git -C "$dest" reset -q --hard "origin/$REF"
  else
    local url="https://github.com/${slug}.git"
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
      url="https://x-access-token:${GITHUB_TOKEN}@github.com/${slug}.git"
    fi
    git clone --depth 1 --branch "$REF" "$url" "$dest"
  fi
  chmod +x "$dest/scripts/"* 2>/dev/null || true
}

clone_repo "$LIP_ORG" "$DEST_ROOT/lip"
clone_repo "$LIT_ORG" "$DEST_ROOT/lit"
echo "ecosystem siblings: $DEST_ROOT/lip $DEST_ROOT/lit @ ${REF}"
