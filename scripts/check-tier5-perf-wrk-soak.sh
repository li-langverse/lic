#!/usr/bin/env bash
# gap-phase2-perf-wrk-soak: full wrk timing vs nginx (parity + parity_streaming + nextjs).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
HARNESS="$ROOT/benchmarks/harness"
export PYTHONPATH="$HARNESS${PYTHONPATH:+:$PYTHONPATH}"
export LI_HTTPD_BIN="$HTTPD"
export PATH="/usr/sbin:/usr/local/bin:${PATH:-}"

if [[ ! -x "$HTTPD" ]]; then
  echo "check-tier5-perf-wrk-soak: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

NGINX_BIN="$(PYTHONPATH="$HARNESS" python3 -c 'from http_bench_servers import resolve_nginx_binary; print(resolve_nginx_binary() or "")')"
if [[ -z "$NGINX_BIN" ]]; then
  echo "==> build-tier5-nginx-oracle.sh (vendored nginx)"
  "$ROOT/scripts/build-tier5-nginx-oracle.sh"
  NGINX_BIN="$(PYTHONPATH="$HARNESS" python3 -c 'from http_bench_servers import resolve_nginx_binary; print(resolve_nginx_binary() or "")')"
fi
if [[ -z "$NGINX_BIN" ]]; then
  echo "check-tier5-perf-wrk-soak: nginx oracle missing (build-tier5-nginx-oracle.sh)" >&2
  exit 1
fi

WRK_BIN="${WRK_BIN:-$(command -v wrk 2>/dev/null || true)}"
for cand in "${WRK_BIN}" "$(command -v wrk 2>/dev/null)" /usr/bin/wrk /usr/local/bin/wrk; do
  if [[ -n "${cand:-}" && -x "$cand" && ! -d "$cand" ]]; then
    WRK_BIN="$cand"
    break
  fi
done
if [[ -z "${WRK_BIN:-}" || ! -x "$WRK_BIN" || -d "$WRK_BIN" ]]; then
  echo "check-tier5-perf-wrk-soak: need wrk on PATH or WRK_BIN (got wrk=missing)" >&2
  exit 1
fi
export WRK_BIN
export PATH="$(dirname "$WRK_BIN"):${PATH}"

DUR="${HTTPD_BENCH_DURATION_SEC:-30}"
export HTTPD_BENCH_SKIP_TIMING=0
export HTTPD_BENCH_DURATION_SEC="$DUR"

# Phase-2 soak: full regression gate (parity + parity_streaming + nextjs + exploit compare).
echo "==> perf wrk soak (${DUR}s, HTTPD_BENCH_SKIP_TIMING=0) — parity + parity_streaming + nextjs"
"$ROOT/scripts/check-tier5-nginx-perf-regression-gate.sh"
echo "check-tier5-perf-wrk-soak: OK"
