#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-decorator: lic not built" >&2; exit 1; }
DECOR="$ROOT/li-tests/decorators/parallel_with_disjoint.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
echo "$out" | grep -q 'mir_parallel_disjoint=1'
echo "$out" | grep -q 'mir_parallel_policy=static_chunk'
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
"$LIC" build "$DECOR" -o "$tmp/par" --release --cores=4 >/dev/null
if command -v llvm-nm >/dev/null 2>&1; then llvm-nm "$tmp/par" | grep -qE 'li_parallel_for_(i64|reduce_add_f64)'
elif command -v nm >/dev/null 2>&1; then nm "$tmp/par" | grep -qE 'li_parallel_for_(i64|reduce_add_f64)'
else echo "check-mir-parallel-decorator: skip parallel symbol check" >&2
fi
"$ROOT/li-tests/run_all.sh" race_shared_memory >/dev/null
echo check-mir-parallel-decorator: ok
