#!/usr/bin/env bash
# PH-7d/G-dec: @parallel on def lowers to MirDecorator.parallel (7d-b proc tag).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-proc-decorator: lic not built" >&2; exit 1; }
DECOR="$ROOT/li-tests/decorators/parallel_with_disjoint.li"
out="$("$LIC" verify "$DECOR" 2>&1)"
echo "$out" | grep -q 'mir_parallel_proc=1'
echo "$out" | grep -q 'mir_parallel_disjoint=1'
"$ROOT/li-tests/run_all.sh" decorators >/dev/null
echo check-mir-parallel-proc-decorator: ok
