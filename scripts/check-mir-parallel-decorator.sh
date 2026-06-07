#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-decorator: lic not built" >&2; exit 1; }
DECOR="$ROOT/li-tests/decorators/parallel_with_disjoint.li"
INHERIT="$ROOT/li-tests/decorators/parallel_def_disjoint_inherit.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
echo "$out" | grep -qE 'mir_parallel_disjoint=[1-9]'
inherit_out="$("$LIC" verify "$INHERIT" 2>&1)"
echo "$inherit_out" | grep -qE 'mir_parallel_disjoint=[1-9]'
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
"$LIC" build "$DECOR" -o "$tmp/par" --release >/dev/null
nm_bin=""
for cand in llvm-nm "llvm-nm-${LI_LLVM_MAJOR:-22}" nm; do
  if command -v "$cand" >/dev/null 2>&1; then nm_bin="$cand"; break; fi
done
if [[ -n "$nm_bin" ]]; then
  grep -q 'li_omp_parallel_for_i64' < <("$nm_bin" "$tmp/par" 2>/dev/null)
else
  echo "check-mir-parallel-decorator: skip OpenMP symbol check" >&2
fi
"$ROOT/li-tests/run_all.sh" race_shared_memory >/dev/null
echo check-mir-parallel-decorator: ok
