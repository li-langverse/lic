#!/usr/bin/env bash
# gap-phase2-perf-wrk-soak: full wrk timing vs nginx (parity + parity_streaming + nextjs).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
TIER5="$ROOT/benchmarks/tier5_http"
NGINX_ORACLE="$TIER5/.nginx-prefix/sbin/nginx"
WRK_ORACLE="$TIER5/.wrk-bin/wrk"

if [[ ! -x "$HTTPD" ]]; then
  echo "check-tier5-perf-wrk-soak: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

if [[ ! -x "$NGINX_ORACLE" ]]; then
  echo "==> building tier5 nginx oracle"
  "$ROOT/scripts/build-tier5-nginx-oracle.sh"
fi
if [[ ! -x "$WRK_ORACLE" ]]; then
  echo "==> building tier5 wrk"
  "$ROOT/scripts/build-tier5-wrk.sh"
fi

NGINX_BIN="$(PATH="$TIER5/.nginx-prefix/sbin:/usr/sbin:/usr/local/bin:$PATH" command -v nginx 2>/dev/null || true)"
WRK_BIN="$(PATH="$TIER5/.wrk-bin:$PATH" command -v wrk 2>/dev/null || true)"
if [[ -z "$NGINX_BIN" || -z "$WRK_BIN" ]]; then
  echo "check-tier5-perf-wrk-soak: need nginx + wrk (got nginx=${NGINX_BIN:-missing} wrk=${WRK_BIN:-missing})" >&2
  exit 1
fi

DUR="${HTTPD_BENCH_DURATION_SEC:-30}"
export HTTPD_BENCH_SKIP_TIMING=0
export HTTPD_BENCH_DURATION_SEC="$DUR"
export HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_RPS_RATIO_MIN:-0.85}"
export HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_TTFB_RATIO_MIN:-0.85}"
export HTTPD_BENCH_P99_RATIO_MAX="${HTTPD_BENCH_P99_RATIO_MAX:-2.0}"
export PATH="$TIER5/.wrk-bin:$TIER5/.nginx-prefix/sbin:/usr/sbin:/usr/local/bin:${PATH:-}"

echo "==> perf wrk soak (${DUR}s, HTTPD_BENCH_SKIP_TIMING=0) — parity + parity_streaming + nextjs"

echo "==> tier5 agent-gateway parity (m1-nginx-bench-parity)"
HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_PARITY_RPS_RATIO_MIN:-0.95}" \
  HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_PARITY_TTFB_RATIO_MIN:-0.85}" \
  "$ROOT/scripts/check-tier5-nginx-bench-parity.sh"

echo "==> tier5 streaming parity (parity_streaming)"
HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_STREAMING_RPS_RATIO_MIN:-0.85}" \
  HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_STREAMING_TTFB_RATIO_MIN:-0.85}" \
  "$ROOT/scripts/check-tier5-streaming-soak.sh"

echo "==> tier5 nextjs proxy parity (gap-nextjs-toy-bench)"
HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_NEXTJS_RPS_RATIO_MIN:-0.85}" \
  HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_NEXTJS_TTFB_RATIO_MIN:-0.85}" \
  "$ROOT/scripts/check-tier5-nextjs-parity.sh"

echo "==> tier5 exploit runtime + nginx compare (gap-nginx-perf-regression-gate tail)"
HARNESS="$ROOT/benchmarks/harness"
export PYTHONPATH="$HARNESS${PYTHONPATH:+:$PYTHONPATH}"
export LI_HTTPD_BIN="$HTTPD"
"$ROOT/scripts/check-tier5-exploit-runtime.sh"
EXPLOIT_PROFILE="${HTTPD_REGRESSION_EXPLOIT_PROFILE:-pr}"
EXPLOIT_OUT="${HTTPD_REGRESSION_EXPLOIT_CSV:-$ROOT/benchmarks/results/tier5_exploit_regression.csv}"
unset TIER5_EXPLOIT_STUB
python3 "$HARNESS/exploit_http.py" \
  --profile "$EXPLOIT_PROFILE" \
  --compare-nginx \
  --fail-on-regression \
  --out "$EXPLOIT_OUT"

echo "check-tier5-perf-wrk-soak: OK"
