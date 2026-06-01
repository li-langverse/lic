#!/usr/bin/env bash
# gap-nginx-perf-regression-gate: tier5 parity + nextjs + exploit compare vs nginx.
# Fails when li p99 > 2× nginx (bench profiles) or an exploit row regresses (nginx pass, li fail).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
HARNESS="$BENCHMARKS_ROOT/harness"
export PYTHONPATH="$TIER5_PYTHONPATH"
export LI_HTTPD_BIN="$HTTPD"
export PATH="/usr/sbin:/usr/local/bin:${PATH:-}"

# Default pass bars (override in nightly for longer runs).
export HTTPD_BENCH_P99_RATIO_MAX="${HTTPD_BENCH_P99_RATIO_MAX:-2.0}"
export HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_RPS_RATIO_MIN:-0.95}"
export HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_TTFB_RATIO_MIN:-0.85}"

if [[ ! -x "$HTTPD" ]]; then
  echo "check-tier5-nginx-perf-regression-gate: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

chmod +x \
  "$ROOT/scripts/check-tier5-nginx-bench-parity.sh" \
  "$ROOT/scripts/check-tier5-nextjs-parity.sh" \
  "$ROOT/scripts/check-tier5-exploit-runtime.sh" \
  "$HARNESS/exploit_http.py" 2>/dev/null || true

echo "==> tier5 agent-gateway parity (m1-nginx-bench-parity)"
HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_RPS_RATIO_MIN:-0.95}" \
  "$ROOT/scripts/check-tier5-nginx-bench-parity.sh"

echo "==> tier5 nextjs proxy parity (gap-nextjs-toy-bench)"
HTTPD_BENCH_RPS_RATIO_MIN="${HTTPD_BENCH_NEXTJS_RPS_RATIO_MIN:-0.85}" \
  HTTPD_BENCH_TTFB_RATIO_MIN="${HTTPD_BENCH_NEXTJS_TTFB_RATIO_MIN:-0.85}" \
  "$ROOT/scripts/check-tier5-nextjs-parity.sh"

echo "==> tier5 exploit runtime (live li-httpd)"
"$ROOT/scripts/check-tier5-exploit-runtime.sh"

# Runtime phase starts li-httpd per exploit; ensure listeners are gone before nginx↔li compare.
pkill -9 -f '[/]build/li-httpd' 2>/dev/null || true
pkill -9 nginx 2>/dev/null || true
sleep 3

EXPLOIT_PROFILE="${HTTPD_REGRESSION_EXPLOIT_PROFILE:-pr}"
EXPLOIT_OUT="${HTTPD_REGRESSION_EXPLOIT_CSV:-$BENCHMARKS_RESULTS/tier5_exploit_regression.csv}"

# Li-only exploits (RNG, leak censor, h2) run in check-tier5-exploit-runtime.sh; re-running
# them in --compare-nginx re-binds the same pick_port() and flakes with "Address already in use".
# slowloris: nginx legitimate_client_ok flakes on shared CI after half-open drain (li passes);
# covered in check-tier5-exploit-runtime.sh — skip nginx↔li compare until benchmarks#302 lands.
HTTPD_TIER5_SKIP_NGINX_COMPARE="${HTTPD_TIER5_SKIP_NGINX_COMPARE:-slowloris}"
mapfile -t COMPARE_EXPLOIT_IDS < <(
  python3 -c "
import os
import sys
sys.path.insert(0, '${HARNESS}')
from http_exploit_toml import list_exploit_ids, merge_exploit, target_langs
skip = {x.strip() for x in os.environ.get('HTTPD_TIER5_SKIP_NGINX_COMPARE', '').split(',') if x.strip()}
for eid in list_exploit_ids(profile='${EXPLOIT_PROFILE}', explicit=None):
    if eid in skip:
        continue
    langs = target_langs(merge_exploit(eid, profile='${EXPLOIT_PROFILE}'), cli_langs=None)
    if 'nginx' in langs:
        print(eid)
"
)
if [[ ${#COMPARE_EXPLOIT_IDS[@]} -eq 0 ]]; then
  echo "check-tier5-nginx-perf-regression-gate: no nginx-capable exploits for profile ${EXPLOIT_PROFILE}" >&2
  exit 1
fi

echo "==> tier5 exploit nginx compare (profile ${EXPLOIT_PROFILE}, ${#COMPARE_EXPLOIT_IDS[@]} rows, fail on regression)"
unset TIER5_EXPLOIT_STUB
python3 "$HARNESS/exploit_http.py" \
  "${COMPARE_EXPLOIT_IDS[@]}" \
  --profile "$EXPLOIT_PROFILE" \
  --compare-nginx \
  --fail-on-regression \
  --out "$EXPLOIT_OUT"

echo "check-tier5-nginx-perf-regression-gate: OK"
