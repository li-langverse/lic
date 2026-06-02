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
# tier5 slowloris nginx flake: retry legitimate GET after attack (benchmarks e49c6c8).
BENCHMARKS_REF="${BENCHMARKS_REF:-fix/tier5-slowloris-nginx-flake-retry}"

clone_repo() {
  local slug="$1" dest="$2" ref="$3"
  local attempt=0
  while [[ "$attempt" -lt 3 ]]; do
    if [[ -d "$dest/.git" ]]; then
      if git -C "$dest" fetch --depth 1 origin "$ref" \
        && git -C "$dest" checkout -q "$ref" \
        && git -C "$dest" reset -q --hard "origin/$ref"; then
        break
      fi
    elif git clone --depth 1 --branch "$ref" "https://github.com/${slug}.git" "$dest"; then
      break
    fi
    attempt=$((attempt + 1))
    rm -rf "$dest"
    sleep 2
  done
  [[ -d "$dest/.git" ]] || {
    echo "checkout-ecosystem-siblings: failed to clone ${slug}@${ref}" >&2
    return 1
  }
  chmod +x "$dest/scripts/"* 2>/dev/null || true
}

clone_repo "$LIP_ORG" "$PARENT/lip" "$REF"
clone_repo "$LIT_ORG" "$PARENT/lit" "$REF"
if ! clone_repo "$BENCHMARKS_ORG" "$PARENT/benchmarks" "$BENCHMARKS_REF"; then
  echo "checkout-ecosystem-siblings: retry benchmarks@${BENCHMARKS_REF} with main" >&2
  BENCHMARKS_REF=main
  clone_repo "$BENCHMARKS_ORG" "$PARENT/benchmarks" main
fi
echo "ecosystem siblings: $PARENT/lip $PARENT/lit $PARENT/benchmarks (lip/lit@${REF} benchmarks@${BENCHMARKS_REF})"
