#!/usr/bin/env bash
# Copy pure-Li num_* fast paths + hoisted C overrides into benchmarks checkout (WP-PAR-40+).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

FAST_SRC="$ROOT/packages/li-parallel/benchmarks/num-fast-src"
STUB_SRC="$ROOT/packages/li-parallel/benchmarks/num-stub-src"
OVERRIDE_SRC="$ROOT/packages/li-parallel/benchmarks/overrides/num"

if [[ ! -d "$FAST_SRC" ]]; then
  echo "lipar-apply-num-fast: missing $FAST_SRC" >&2
  exit 1
fi

if [[ ! -f "${BENCHMARKS_ROOT}/catalog.toml" ]]; then
  _cache="$ROOT/.cache/li-benchmarks"
  if [[ -f "$_cache/catalog.toml" ]]; then
    BENCHMARKS_ROOT="$_cache"
    export BENCHMARKS_ROOT
  fi
fi

# Benches that use extern stub + hoisted C core (not pure Li).
C_OVERRIDE_BENCHES=(
  num_cg
  num_eig_symmetric
  num_integ_rk4
  num_integ_semi_implicit
  num_integ_verlet
  num_opt_bfgs
  num_quadrature_gauss
)

applied_li=0
while IFS= read -r -d '' src; do
  rel="${src#"$FAST_SRC"/}"
  bench="${rel#benchmarks/workloads/tier1_micro/}"
  bench="${bench%/li/main.li}"
  skip=0
  for cbench in "${C_OVERRIDE_BENCHES[@]}"; do
    if [[ "$bench" == "$cbench" ]]; then
      skip=1
      break
    fi
  done
  if [[ "$skip" -eq 1 ]]; then
    continue
  fi
  dest="${BENCHMARKS_ROOT}/${rel}"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  applied_li=$((applied_li + 1))
done < <(find "$FAST_SRC" -name 'main.li' -print0)

applied_stub=0
if [[ -d "$STUB_SRC" ]]; then
  while IFS= read -r -d '' src; do
    rel="${src#"$STUB_SRC"/}"
    dest="${BENCHMARKS_ROOT}/${rel}"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    applied_stub=$((applied_stub + 1))
  done < <(find "$STUB_SRC" -name 'main.li' -print0)
fi

applied_c=0
if [[ -d "$OVERRIDE_SRC" ]]; then
  for cfile in "$OVERRIDE_SRC"/*_core.c; do
    [[ -f "$cfile" ]] || continue
    base="$(basename "$cfile")"
    bench="${base%_core.c}"
    dest="${BENCHMARKS_ROOT}/benchmarks/workloads/tier1_micro/${bench}/common/${base}"
    if [[ -f "$dest" ]]; then
      cp "$cfile" "$dest"
      applied_c=$((applied_c + 1))
    fi
  done
fi

echo "lipar-apply-num-fast: applied $applied_li pure-Li main(s), $applied_stub stub(s), $applied_c C override(s) to $BENCHMARKS_ROOT"
