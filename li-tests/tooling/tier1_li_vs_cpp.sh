#!/usr/bin/env bash
# Smoke: run check-tier1-li-vs-cpp.sh on fixture CSV when latest.csv is absent.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/check-tier1-li-vs-cpp.sh"
FIXTURE="$ROOT/li-tests/fixtures/tier1_math_perf_smoke.csv"
LATEST="$ROOT/benchmarks/results/latest.csv"
if [[ -z "${LI_TIER1_PERF_CSV:-}" ]]; then
  if [[ -f "$LATEST" ]]; then
    export LI_TIER1_PERF_CSV="$LATEST"
  else
    export LI_TIER1_PERF_CSV="$FIXTURE"
    echo "tier1_li_vs_cpp: no benchmarks/results/latest.csv — using $FIXTURE"
  fi
fi
export LI_TIER1_PERF_STRICT="${LI_TIER1_PERF_STRICT:-0}"
"$ROOT/scripts/check-tier1-li-vs-cpp.sh"
echo "tier1_li_vs_cpp: ok"
