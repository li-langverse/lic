#!/usr/bin/env bash
# HTTP parse fuzz smoke — sec-r1 gate (libFuzzer ≤120s, no crash).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FUZZ="${HTTP_PARSE_FUZZ:-$ROOT/build-fuzz/compiler/fuzz/http_parse_fuzz}"
CORPUS="${HTTP_PARSE_FUZZ_CORPUS:-$ROOT/compiler/fuzz/corpus/http}"
MAX_TIME="${HTTPD_FUZZ_MAX_TIME:-120}"
MAX_LEN="${HTTPD_FUZZ_MAX_LEN:-65536}"

if [[ ! -x "$FUZZ" ]]; then
  echo "httpd-fuzz-smoke: skip (http_parse_fuzz not built at $FUZZ)" >&2
  exit 0
fi

mkdir -p "$CORPUS"
if [[ -z "$(find "$CORPUS" -maxdepth 1 -type f 2>/dev/null | head -1)" ]]; then
  printf 'GET / HTTP/1.1\r\nHost: localhost\r\n\r\n' >"$CORPUS/seed_get"
  python3 -c 'print("GET " + "/" * 4000 + " HTTP/1.1\r\n\r\n")' >"$CORPUS/seed_overlong_line"
  printf 'BADMETHOD / HTTP/1.1\r\n\r\n' >"$CORPUS/seed_bad_method"
fi

echo "httpd-fuzz-smoke: running $FUZZ (max_total_time=${MAX_TIME}s)"
"$FUZZ" "$CORPUS" -max_total_time="$MAX_TIME" -max_len="$MAX_LEN"
echo "httpd-fuzz-smoke: ok"
