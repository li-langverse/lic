#!/usr/bin/env bash
# lic#619 / #477: run phase2 wrk timing gates before closing httpd plan_debt rows.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export HTTPD_BENCH_SKIP_TIMING=0
export HTTPD_BENCH_DURATION_SEC="${HTTPD_BENCH_DURATION_SEC:-30}"

echo "verify-httpd-phase2-wrk-gates: HTTPD_BENCH_SKIP_TIMING=0 duration=${HTTPD_BENCH_DURATION_SEC}s"
"$ROOT/scripts/check-tier5-perf-wrk-soak.sh"
"$ROOT/scripts/check-tier5-streaming-soak.sh"
echo "verify-httpd-phase2-wrk-gates: OK"
