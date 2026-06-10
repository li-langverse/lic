#!/bin/sh
# 10x TLS CSS probe through li-httpd - models workstation curl acceptance.
set -eu

ENV_SH="/proxy-curl-env.sh"
[ -f "$ENV_SH" ] || ENV_SH="$(dirname "$0")/../proxy/proxy-curl-env.sh"
eval "$(sh "$ENV_SH")"
if [ "${PROXY_USE_CONNECT:-0}" = 1 ]; then
  PROXY_CURL="--connect-to ${PROXY_VHOST}:${PROXY_PORT}:${PROXY_CONNECT_HOST}:${PROXY_PORT}"
else
  PROXY_CURL="--resolve ${PROXY_RESOLVE}"
fi
EXPECTED="${EXPECTED_BYTES:-835437}"
RUNS="${RUNS:-10}"
SLEEP="${PROBE_SLEEP:-0.2}"

pass=0
i=1
while [ "$i" -le "$RUNS" ]; do
  sign=$(curl -sk --tls-max 1.2 --http1.1 --no-keepalive $PROXY_CURL --max-time 30 \
    -o /dev/null -w '%{http_code}' "https://${PROXY_VHOST}:${PROXY_PORT}/users/sign_in" 2>/dev/null || echo 000)
  css=$(curl -sk --tls-max 1.2 --http1.1 --no-keepalive $PROXY_CURL --max-time 120 \
    -o /dev/null -w '%{size_download}' "https://${PROXY_VHOST}:${PROXY_PORT}/assets/application-deadbeef.css" 2>/dev/null || echo 0)
  ok=no
  case "$sign" in 200|302) [ "$css" = "$EXPECTED" ] && ok=yes && pass=$((pass + 1)) ;; esac
  echo "run $i: sign=$sign css_bytes=$css ok=$ok"
  i=$((i + 1))
  sleep "$SLEEP"
done
echo "RESULT local-container: ${pass}/${RUNS}"
[ "$pass" -eq "$RUNS" ]
