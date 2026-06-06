#!/usr/bin/env bash
# Smoke: killer gate script exists and progress slice passes with LIPAR_KILLER_SKIP_FULL=1.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GATE="$ROOT/scripts/check-li-parallel-killer-gate.sh"
[[ -f "$GATE" ]] || { echo "li_parallel_killer_gate_smoke: missing $GATE" >&2; exit 1; }
chmod +x "$GATE"
export LIC_ROOT="$ROOT"
export SKIP_BUILD=1
export BENCH_RUNS=1
export LIPAR_KILLER_SKIP_FULL=1
export LI_LIPAR_PERF_STRICT=0
"$GATE"
echo "li_parallel_killer_gate_smoke: ok"
