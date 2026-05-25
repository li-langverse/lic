#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
OUT="$ROOT/build/mir_par_check/out"
rm -rf "$ROOT/build/mir_par_check"
mkdir -p "$(dirname "$OUT")"
"$LIC" build "$ROOT/li-tests/decorators/parallel_def_disjoint_inherit.li" -o "$OUT" 2>/dev/null
nm "$OUT" 2>/dev/null | grep -q li_omp_parallel_for
echo check_mir_parallel_decorator: ok
