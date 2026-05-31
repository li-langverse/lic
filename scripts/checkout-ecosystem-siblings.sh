#!/usr/bin/env bash
# Clone li-langverse/lip, lit, and benchmarks beside lic (CI and local smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(cd "$ROOT/.." && pwd)"
LIP_ORG="${LIP_ORG:-li-langverse/lip}"
LIT_ORG="${LIT_ORG:-li-langverse/lit}"
BENCHMARKS_ORG="${BENCHMARKS_ORG:-li-langverse/benchmarks}"
REF="${ECOSYSTEM_REF:-main}"
# Until benchmarks#276 merges: tier-0 stability.py paths after repo split.
BENCHMARKS_REF="${BENCHMARKS_REF:-fix/stability-paths-post-split}"

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

clone_repo "$LIP_ORG" "$PARENT/lip" "$REF"
clone_repo "$LIT_ORG" "$PARENT/lit" "$REF"
clone_repo "$BENCHMARKS_ORG" "$PARENT/benchmarks" "$BENCHMARKS_REF"
echo "ecosystem siblings: $PARENT/lip $PARENT/lit $PARENT/benchmarks (lip/lit@${REF} benchmarks@${BENCHMARKS_REF})"
