#!/usr/bin/env bash
# Clone li-langverse/lip and lit beside lic (CI and local smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(cd "$ROOT/.." && pwd)"
LIP_ORG="${LIP_ORG:-li-langverse/lip}"
LIT_ORG="${LIT_ORG:-li-langverse/lit}"
LIP_REF="${LIP_REF:-${ECOSYSTEM_REF:-main}}"
LIT_REF="${LIT_REF:-${ECOSYSTEM_REF:-main}}"

clone_repo() {
  local slug="$1" dest="$2" ref="$3"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" fetch --depth 1 origin "$ref"
    git -C "$dest" checkout -q "$ref"
    git -C "$dest" reset -q --hard "origin/$ref"
  else
    git clone --depth 1 --branch "$ref" "https://github.com/${slug}.git" "$dest"
  fi
  chmod +x "$dest/scripts/"* 2>/dev/null || true
}

clone_repo "$LIP_ORG" "$PARENT/lip" "$LIP_REF"
clone_repo "$LIT_ORG" "$PARENT/lit" "$LIT_REF"
echo "ecosystem siblings: $PARENT/lip @ ${LIP_REF}, $PARENT/lit @ ${LIT_REF}"
