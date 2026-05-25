#!/usr/bin/env bash
# gap-nginx-perf-regression-gate: tier5 parity + nextjs + exploit compare vs nginx.
# Fails when li p99 > 2× nginx (bench profiles) or an exploit row regresses (nginx pass, li fail).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
HARNESS="$ROOT/benchmarks/harness"
export PYTHONPATH="$HARNESS${PYTHONPATH:+:$PYTHONPATH}"
export LI_HTTPD_BIN="$HTTPD"
export PATH="/usr/sbin:/usr/local/bin:${PATH:-}"

# Default pass bars (override in nightly for longer runs). Scenario bench.toml [parity] may tighten/relax per row.
export HTTPD_BENCH_P99_RATIO_MAX="${HTTPD_BENCH_P99_RATIO_MAX:-2.0}"
export HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_RPS_RATIO_MIN:-0.95}"
export HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_TTFB_RATIO_MIN:-0.85}"
# Next.js proxy loopback documented variants (see nextjs_parity_variants.toml).
export HTTPD_BENCH_NEXTJS_RPS_RATIO_MIN="${HTTPD_BENCH_NEXTJS_RPS_RATIO_MIN:-0.80}"
export HTTPD_BENCH_NEXTJS_TTFB_RATIO_MIN="${HTTPD_BENCH_NEXTJS_TTFB_RATIO_MIN:-0.85}"

if [[ ! -x "$HTTPD" ]]; then
  echo "check-tier5-nginx-perf-regression-gate: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

chmod +x \
  "$ROOT/scripts/check-tier5-nginx-bench-parity.sh" \
  "$ROOT/scripts/check-tier5-nextjs-parity.sh" \
  "$ROOT/scripts/check-tier5-exploit-runtime.sh" \
  "$HARNESS/bench_http.py" \
  "$HARNESS/verify_http.py" \
  "$HARNESS/exploit_http.py" 2>/dev/null || true
chmod +x "$ROOT/benchmarks/tier5_http/fixtures/streaming-soak/server.py" 2>/dev/null || true

echo "==> tier5 agent-gateway parity (m1-nginx-bench-parity)"
HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_PARITY_RPS_RATIO_MIN:-${HTTPD_BENCH_RPS_RATIO_MIN:-0.95}}" \
  "$ROOT/scripts/check-tier5-nginx-bench-parity.sh"

if [[ "${HTTPD_BENCH_SKIP_TIMING:-0}" != "1" ]] && command -v wrk >/dev/null 2>&1; then
  NGINX_BIN="$(PYTHONPATH="$HARNESS" python3 -c 'from http_bench_servers import resolve_nginx_binary; print(resolve_nginx_binary() or "")')"
  if [[ -n "$NGINX_BIN" ]]; then
    DUR="${HTTPD_BENCH_DURATION_SEC:-8}"
    echo "==> tier5 streaming wrk parity (parity_streaming, ${DUR}s)"
    HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_STREAMING_RPS_RATIO_MIN:-0.85}" \
      HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_STREAMING_TTFB_RATIO_MIN:-0.85}" \
      HTTPD_BENCH_P99_RATIO_MAX="${HTTPD_BENCH_P99_RATIO_MAX:-2.0}" \
      python3 "$HARNESS/bench_http.py" --profile parity_streaming --check-parity \
        --set "load.duration_sec=${DUR}" \
        --out "$ROOT/benchmarks/results/tier5_streaming_parity.csv"
  fi
fi

echo "==> tier5 nextjs proxy parity (gap-nextjs-toy-bench)"
HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_NEXTJS_RPS_RATIO_MIN:-0.85}" \
  HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_NEXTJS_TTFB_RATIO_MIN:-0.85}" \
  "$ROOT/scripts/check-tier5-nextjs-parity.sh"

echo "==> tier5 exploit runtime (live li-httpd)"
"$ROOT/scripts/check-tier5-exploit-runtime.sh"

EXPLOIT_PROFILE="${HTTPD_REGRESSION_EXPLOIT_PROFILE:-pr}"
EXPLOIT_OUT="${HTTPD_REGRESSION_EXPLOIT_CSV:-$ROOT/benchmarks/results/tier5_exploit_regression.csv}"

echo "==> tier5 exploit nginx compare (profile ${EXPLOIT_PROFILE}, fail on regression)"
unset TIER5_EXPLOIT_STUB
python3 "$HARNESS/exploit_http.py" \
  --profile "$EXPLOIT_PROFILE" \
  --compare-nginx \
  --fail-on-regression \
  --out "$EXPLOIT_OUT"

echo "check-tier5-nginx-perf-regression-gate: OK"
