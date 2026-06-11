#!/usr/bin/env bash
# PH-7e / lic#6 — Kokkos-class portable parallel lowering gate.
# @parallel(disjoint=…) → li_parallel_for_i64; @cpu/@gpu → memory-space policy (G-dec slice).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-portable-parallel-lowering: lic not built" >&2; exit 1; }

DECOR="$ROOT/li-tests/decorators/portable_parallel_lowering_ok.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
echo "$out" | grep -q 'mir_parallel_disjoint=1' || {
  echo "check-mir-portable-parallel-lowering: expected mir_parallel_disjoint=1" >&2
  exit 1
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
par_ll="$tmp/portable_parallel.ll"
export LI_EMIT_LL="$par_ll"
"$LIC" build "$DECOR" -o /dev/null --release >/dev/null
[[ -f "$par_ll" ]] || { echo "check-mir-portable-parallel-lowering: missing LLVM IR" >&2; exit 1; }
grep -qE 'call.*(li_parallel_for_i64|li_omp_parallel_for_i64)' "$par_ll" || {
  echo "check-mir-portable-parallel-lowering: LLVM IR must call li_parallel_for_i64" >&2
  exit 1
}

"$ROOT/scripts/check-mir-parallel-decorator.sh"
"$ROOT/li-tests/run_all.sh" decorators >/dev/null
echo check-mir-portable-parallel-lowering: ok
