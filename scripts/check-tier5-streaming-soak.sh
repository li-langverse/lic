#!/usr/bin/env bash
# gap-tier5-streaming-soak: SSE long stream + WS fanout vs nginx on live li-httpd.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
HARNESS="$BENCHMARKS_ROOT/harness"
export PYTHONPATH="$HARNESS${PYTHONPATH:+:$PYTHONPATH}"
export LI_HTTPD_BIN="$HTTPD"
export PATH="/usr/sbin:/usr/local/bin:${PATH:-}"

if [[ ! -x "$HTTPD" ]]; then
  echo "check-tier5-streaming-soak: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

chmod +x "$HARNESS/bench_http.py" "$HARNESS/verify_http.py" 2>/dev/null || true
chmod +x "$BENCHMARKS_WORKLOADS/tier5_http/fixtures/streaming-soak/server.py" 2>/dev/null || true

echo "==> verify_http.py --profile streaming_ci (SSE + WS edge)"
python3 "$HARNESS/verify_http.py" --profile streaming_ci

NGINX_BIN="$(PYTHONPATH="$HARNESS" python3 -c 'from http_bench_servers import resolve_nginx_binary; print(resolve_nginx_binary() or "")')"
if [[ -z "$NGINX_BIN" ]]; then
  echo "check-tier5-streaming-soak: nginx missing — verify-only OK" >&2
  echo "check-tier5-streaming-soak: OK"
  exit 0
fi

if [[ "${HTTPD_BENCH_SKIP_TIMING:-0}" == "1" ]]; then
  echo "check-tier5-streaming-soak: skip timing (HTTPD_BENCH_SKIP_TIMING=1)"
  echo "check-tier5-streaming-soak: OK"
  exit 0
fi

DUR="${HTTPD_BENCH_DURATION_SEC:-6}"
export HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_RPS_RATIO_MIN:-0.85}"
export HTTPD_BENCH_P99_RATIO_MAX="${HTTPD_BENCH_P99_RATIO_MAX:-2.0}"

echo "==> bench_http.py --profile parity_streaming --check-parity (soak ${DUR}s, li vs nginx)"
python3 "$HARNESS/bench_http.py" --profile parity_streaming --check-parity \
  --set "load.duration_sec=${DUR}" \
  --out "$BENCHMARKS_RESULTS/tier5_streaming_parity.csv"

echo "check-tier5-streaming-soak: OK"
