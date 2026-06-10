#!/bin/sh
# Parallel same-asset fairness gate: 6 concurrent 1.3MB CL responses, wc==CL.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
WC_TEST="${PARALLEL_WC_TEST:-$ROOT/test/proxy-repro/parallel-wc-test.sh}"
if [ ! -f "$WC_TEST" ] && [ -f /parallel-wc-test.sh ]; then
  WC_TEST=/parallel-wc-test.sh
fi
export PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
export PROXY_PORT="${PROXY_PORT:-18443}"
export PARALLEL_N="${PARALLEL_N:-6}"
export EXPECTED_BYTES="${EXPECTED_BYTES:-1321365}"
export CURL_EXTRA="${CURL_EXTRA:---http1.1 --no-keepalive}"
sh "$WC_TEST"
