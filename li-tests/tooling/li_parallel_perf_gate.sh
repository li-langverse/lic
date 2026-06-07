#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FIXTURE="$ROOT/li-tests/fixtures/lipar-dual-mode-pr.csv"
chmod +x "$ROOT/scripts/check-li-parallel-perf-gate.sh"
export LI_LIPAR_PERF_STRICT="${LI_LIPAR_PERF_STRICT:-0}"
if [[ -f "$FIXTURE" ]]; then
  export LI_LIPAR_PERF_CSV="$FIXTURE"
fi
"$ROOT/scripts/check-li-parallel-perf-gate.sh"
echo "li_parallel_perf_gate: ok"
