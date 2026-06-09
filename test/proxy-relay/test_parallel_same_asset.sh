#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
export PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
export PROXY_PORT="${PROXY_PORT:-18443}"
export PARALLEL_N="${PARALLEL_N:-6}"
export EXPECTED_BYTES="${EXPECTED_BYTES:-1321365}"
export CURL_EXTRA="${CURL_EXTRA:---http1.1 --no-keepalive}"
sh "$ROOT/test/proxy-repro/parallel-wc-test.sh"
