#!/usr/bin/env bash
# lic#109 — @parallel emits documented static-chunk policy in verify telemetry.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-parallel-policy: lic not built" >&2; exit 1; }

GOOD="$ROOT/li-tests/race_shared_memory/good_disjoint_parallel.li"
out="$("$LIC" verify "$GOOD" 2>&1)"
echo "$out" | grep -q 'mir_parallel_policy=static_chunk'

NEG="$ROOT/li-tests/decorators/cpu_only_ok.li"
neg_out="$("$LIC" verify "$NEG" 2>&1)"
echo "$neg_out" | grep -q 'mir_parallel_policy=none'

"$ROOT/li-tests/tooling/parallel_no_silent_serial_smoke.sh"
echo check-mir-parallel-policy: ok
