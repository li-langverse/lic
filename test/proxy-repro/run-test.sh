#!/bin/sh
# 10x TLS CSS probe through li-httpd — models workstation curl acceptance.
set -eu

HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-18443}"
VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
EXPECTED="${EXPECTED_BYTES:-835437}"
RUNS="${RUNS:-10}"
SLEEP="${PROBE_SLEEP:-0.2}"
RESOLVE="${CURL_RESOLVE:-${VHOST}:${PORT}:${HOST}}"

pass=0
i=1
while [ "$i" -le "$RUNS" ]; do
  sign=$(curl -sk --resolve "$RESOLVE" --max-time 30 \
    -o /dev/null -w '%{http_code}' "https://${VHOST}/users/sign_in" 2>/dev/null || echo 000)
  css=$(curl -sk --resolve "$RESOLVE" --max-time 120 \
    -o /dev/null -w '%{size_download}' "https://${VHOST}/assets/application-deadbeef.css" 2>/dev/null || echo 0)
  ok=no
  case "$sign" in 200|302) [ "$css" = "$EXPECTED" ] && ok=yes && pass=$((pass + 1)) ;; esac
  echo "run $i: sign=$sign css_bytes=$css ok=$ok"
  i=$((i + 1))
  sleep "$SLEEP"
done
echo "RESULT local-container: ${pass}/${RUNS}"
[ "$pass" -eq "$RUNS" ]
