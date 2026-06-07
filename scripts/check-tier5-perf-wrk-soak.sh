#!/usr/bin/env bash
# gap-phase2-perf-wrk-soak: full wrk timing vs nginx (parity + parity_streaming + nextjs).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
HARNESS="$BENCHMARKS_ROOT/harness"
export PYTHONPATH="$HARNESS${PYTHONPATH:+:$PYTHONPATH}"
export LI_HTTPD_BIN="$HTTPD"

if [[ ! -x "$HTTPD" ]]; then
  echo "check-tier5-perf-wrk-soak: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

NGINX_BIN="$(PATH=/usr/sbin:/usr/local/bin:$PATH command -v nginx 2>/dev/null || true)"
WRK_BIN="$(command -v wrk 2>/dev/null || true)"
if [[ -z "$NGINX_BIN" || -z "$WRK_BIN" ]]; then
  echo "check-tier5-perf-wrk-soak: need nginx + wrk on PATH (got nginx=${NGINX_BIN:-missing} wrk=${WRK_BIN:-missing})" >&2
  exit 1
fi

DUR="${HTTPD_BENCH_DURATION_SEC:-30}"
export HTTPD_BENCH_SKIP_TIMING=0
export HTTPD_BENCH_DURATION_SEC="$DUR"
export PATH="/usr/sbin:/usr/local/bin:${PATH:-}"

echo "==> perf wrk soak (${DUR}s) — parity + parity_streaming + nextjs + exploit compare"
"$ROOT/scripts/check-tier5-nginx-perf-regression-gate.sh"

chmod +x "$HARNESS/bench_http.py" 2>/dev/null || true
echo "==> bench_http.py --profile parity_streaming --check-parity (soak ${DUR}s, li vs nginx)"
python3 "$HARNESS/bench_http.py" --profile parity_streaming --check-parity \
  --set "load.duration_sec=${DUR}" \
  --out "$BENCHMARKS_RESULTS/tier5_streaming_parity_wrk.csv"

echo "check-tier5-perf-wrk-soak: OK"
