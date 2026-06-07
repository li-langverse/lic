#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-for-disjoint: lic not built" >&2; exit 1; }
GOOD="$ROOT/li-tests/race_shared_memory/good_disjoint_parallel.li"
out="$("$LIC" verify "$GOOD" 2>&1)"
echo "$out" | grep -q 'mir_parallel_disjoint=1'
"$ROOT/li-tests/run_all.sh" race_shared_memory >/dev/null
echo "check-mir-parallel-for-disjoint: ok"
