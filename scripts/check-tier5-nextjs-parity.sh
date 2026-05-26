#!/usr/bin/env bash
# gap-nextjs-toy-bench: Next.js toy (API/SSR/SSE/WS) proxy scenarios — li RPS/TTFB >= 0.85× nginx.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
HARNESS="$ROOT/benchmarks/harness"
export PYTHONPATH="$HARNESS${PYTHONPATH:+:$PYTHONPATH}"
export LI_HTTPD_BIN="$HTTPD"

if [[ ! -x "$HTTPD" ]]; then
  echo "check-tier5-nextjs-parity: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

export PATH="/usr/sbin:/usr/local/bin:${PATH:-}"

chmod +x "$HARNESS/bench_http.py" "$HARNESS/verify_http.py" 2>/dev/null || true
chmod +x "$ROOT/benchmarks/tier5_http/fixtures/nextjs-toy/server.mjs" 2>/dev/null || true

if ! command -v node >/dev/null 2>&1 && ! command -v nodejs >/dev/null 2>&1; then
  echo "check-tier5-nextjs-parity: node missing — verify-only (set HTTPD_BENCH_SKIP_TIMING=1)" >&2
  export HTTPD_BENCH_SKIP_TIMING=1
fi

echo "==> verify_http.py --profile nextjs_ci (API/SSR/SSE/WS)"
python3 "$HARNESS/verify_http.py" --profile nextjs_ci

if [[ "${HTTPD_BENCH_SKIP_TIMING:-0}" == "1" ]]; then
  echo "check-tier5-nextjs-parity: skip timing (HTTPD_BENCH_SKIP_TIMING=1)"
  echo "check-tier5-nextjs-parity: OK (verify-only)"
  exit 0
fi

if ! command -v wrk >/dev/null 2>&1; then
  echo "check-tier5-nextjs-parity: wrk missing — verify-only OK" >&2
  echo "check-tier5-nextjs-parity: OK"
  exit 0
fi

NGINX_BIN="$(PYTHONPATH="$HARNESS" python3 -c 'from http_bench_servers import resolve_nginx_binary; print(resolve_nginx_binary() or "")')"
if [[ -z "$NGINX_BIN" ]]; then
  echo "check-tier5-nextjs-parity: nginx missing — verify-only OK" >&2
  echo "check-tier5-nextjs-parity: OK"
  exit 0
fi

DUR="${HTTPD_BENCH_DURATION_SEC:-8}"
export HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_RPS_RATIO_MIN:-0.85}"
export HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_TTFB_RATIO_MIN:-0.85}"
export HTTPD_BENCH_P99_RATIO_MAX="${HTTPD_BENCH_P99_RATIO_MAX:-2.0}"

echo "==> bench_http.py --profile nextjs_parity --check-parity (duration ${DUR}s, RPS/TTFB >= ${HTTPD_BENCH_RPS_RATIO_MIN}x nginx)"
python3 "$HARNESS/bench_http.py" --profile nextjs_parity --check-parity \
  nextjs_api nextjs_ssr \
  --set "load.duration_sec=${DUR}" \
  --out "$ROOT/benchmarks/results/tier5_nextjs_parity.csv"

echo "check-tier5-nextjs-parity: OK"
