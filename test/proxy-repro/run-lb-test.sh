#!/bin/sh
# ip_hash across two upstream peers — same client must always see the same X-Li-Backend marker.
set -eu

HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-18444}"
VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
RUNS="${RUNS:-24}"
RESOLVE="${CURL_RESOLVE:-${VHOST}:${PORT}:${HOST}}"

unique_backends() {
  out=/tmp/lb-backends-$$
  : >"$out"
  i=1
  while [ "$i" -le "$RUNS" ]; do
    curl -sk --http1.1 --no-keepalive --resolve "$RESOLVE" --max-time 10 \
      -D - -o /dev/null "https://${VHOST}:${PORT}/probe" 2>/dev/null \
      | tr -d '\r' | awk 'tolower($0) ~ /^x-li-backend:/ {print $2; exit}' >>"$out" || echo fail >>"$out"
    i=$((i + 1))
  done
  sort -u "$out" | grep -vc '^$' || true
}

n="$(unique_backends)"
echo "lb-test: distinct backends=$n (expect 1 for ip_hash)"
[ "$n" = "1" ]
