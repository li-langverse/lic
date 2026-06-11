#!/usr/bin/env bash
# PH-7e/G-par: @cpu + @parallel lowers to portable li_parallel_for_i64 with Host memory space.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-portable-lowering: lic not built" >&2; exit 1; }
DECOR="$ROOT/li-tests/decorators/parallel_with_disjoint.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
echo "$out" | grep -q 'mir_cpu_def=1'
echo "$out" | grep -q 'mir_parallel_disjoint=1'
echo "$out" | grep -q 'mir_parallel_host_lowering=1'
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
par_ll="$tmp/parallel.ll"
export LI_EMIT_LL="$par_ll"
"$LIC" build "$DECOR" -o /dev/null --release >/dev/null
[[ -f "$par_ll" ]] || { echo "check-mir-parallel-portable-lowering: missing LLVM IR" >&2; exit 1; }
sym_re='call.*(li_parallel_for_i64|li_omp_parallel_for_i64)'
grep -qE "$sym_re" "$par_ll" || {
  echo "check-mir-parallel-portable-lowering: Host parallel must call li_parallel_for_i64" >&2
  exit 1
}
"$ROOT/li-tests/run_all.sh" decorators >/dev/null
echo check-mir-parallel-portable-lowering: ok
