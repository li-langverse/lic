#!/usr/bin/env bash
# WP-PAR-48 — copy main_parallel.li overlays from lic into benchmarks checkout.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

OVERLAY="$ROOT/packages/li-parallel/benchmarks/parallel-src"
if [[ ! -d "$OVERLAY" ]]; then
  echo "lipar-apply-parallel-src: missing overlay tree $OVERLAY" >&2
  exit 1
fi

# Prefer full harness checkout (catalog.toml) for coverage audits.
if [[ ! -f "${BENCHMARKS_ROOT}/catalog.toml" ]]; then
  _cache="$ROOT/.cache/li-benchmarks"
  if [[ -f "$_cache/catalog.toml" ]]; then
    BENCHMARKS_ROOT="$_cache"
    export BENCHMARKS_ROOT
  fi
fi

applied=0
while IFS= read -r -d '' src; do
  rel="${src#"$OVERLAY"/}"
  dest="${BENCHMARKS_ROOT}/${rel}"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  applied=$((applied + 1))
done < <(find "$OVERLAY" -name 'main_parallel.li' -print0)

echo "lipar-apply-parallel-src: applied $applied file(s) to $BENCHMARKS_ROOT"
