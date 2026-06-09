#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-decorator: lic not built" >&2; exit 1; }
DECOR="$ROOT/li-tests/decorators/parallel_with_disjoint.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
# `@parallel(disjoint=…)` on def plus nested `parallel for` → def tag + OmpParallelFor site.
echo "$out" | grep -qE 'mir_parallel_disjoint=[2-9]'
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
"$LIC" build "$DECOR" -o "$tmp/par" --release >/dev/null
if command -v llvm-nm >/dev/null 2>&1; then
  grep -q 'li_omp_parallel_for_i64' <(llvm-nm "$tmp/par" 2>/dev/null) \
    || { echo "check-mir-parallel-decorator: missing li_omp_parallel_for_i64" >&2; exit 1; }
elif command -v nm >/dev/null 2>&1; then
  grep -q 'li_omp_parallel_for_i64' <(nm "$tmp/par" 2>/dev/null) \
    || { echo "check-mir-parallel-decorator: missing li_omp_parallel_for_i64" >&2; exit 1; }
else echo "check-mir-parallel-decorator: skip OpenMP symbol check" >&2
fi
"$ROOT/li-tests/run_all.sh" race_shared_memory >/dev/null
echo check-mir-parallel-decorator: ok
