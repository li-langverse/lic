#!/usr/bin/env bash
# Smoke-run http_parse_fuzz for sec-r1 / HTTPD_FUZZ_SMOKE gate (≤120s, no crash).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${HTTP_PARSE_FUZZ_BUILD:-$ROOT/build-fuzz}"
FUZZ="$BUILD/compiler/fuzz/http_parse_fuzz"
CORPUS="$ROOT/compiler/fuzz/corpus/http"
MAX_SEC="${HTTP_PARSE_FUZZ_MAX_SEC:-60}"
RUNS="${HTTP_PARSE_FUZZ_RUNS:-5000}"

if [[ ! -x "$FUZZ" ]]; then
  echo "http-parse-fuzz-smoke: skip (missing $FUZZ — build with LI_BUILD_FUZZ=ON)" >&2
  exit 0
fi

mkdir -p "$CORPUS"
echo "http-parse-fuzz-smoke: $FUZZ corpus=$CORPUS runs=$RUNS max_sec=$MAX_SEC"
if command -v timeout >/dev/null 2>&1; then
  timeout --foreground "$MAX_SEC" "$FUZZ" "$CORPUS" -runs="$RUNS" -max_len=65536
else
  "$FUZZ" "$CORPUS" -runs="$RUNS" -max_len=65536
fi
echo "http-parse-fuzz-smoke: ok"
