#!/usr/bin/env bash
# Clone li-langverse/lip, lit, and benchmarks beside lic (CI and local smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(cd "$ROOT/.." && pwd)"
LIP_ORG="${LIP_ORG:-li-langverse/lip}"
LIT_ORG="${LIT_ORG:-li-langverse/lit}"
BENCHMARKS_ORG="${BENCHMARKS_ORG:-li-langverse/benchmarks}"
REF="${ECOSYSTEM_REF:-main}"

clone_repo() {
  local slug="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" fetch --depth 1 origin "$REF"
    git -C "$dest" checkout -q "$REF"
    git -C "$dest" reset -q --hard "origin/$REF"
  else
    git clone --depth 1 --branch "$REF" "https://github.com/${slug}.git" "$dest"
  fi
  chmod +x "$dest/scripts/"* 2>/dev/null || true
}

clone_repo "$LIP_ORG" "$PARENT/lip"
clone_repo "$LIT_ORG" "$PARENT/lit"
clone_repo "$BENCHMARKS_ORG" "$PARENT/benchmarks"
echo "ecosystem siblings: $PARENT/lip $PARENT/lit $PARENT/benchmarks @ ${REF}"
