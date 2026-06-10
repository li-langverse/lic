#!/bin/sh
# Load balancer e2e: round_robin, least_conn, ip_hash via LB_POLICY env on proxy-lb.
set -eu

ENV_SH="/proxy-curl-env.sh"
[ -f "$ENV_SH" ] || ENV_SH="$(dirname "$0")/../proxy/proxy-curl-env.sh"
eval "$(sh "$ENV_SH")"
if [ "${PROXY_USE_CONNECT:-0}" = 1 ]; then
  PROXY_CURL="--connect-to ${PROXY_VHOST}:${PROXY_PORT}:${PROXY_CONNECT_HOST}:${PROXY_PORT}"
else
  PROXY_CURL="--resolve ${PROXY_RESOLVE}"
fi
POLICY="${LB_POLICY:-ip_hash}"
RUNS="${RUNS:-24}"

unique_backends() {
  out=/tmp/lb-backends-$$
  : >"$out"
  i=1
  while [ "$i" -le "$RUNS" ]; do
    curl -sk --http1.1 --no-keepalive $PROXY_CURL --max-time 10 \
      -D - -o /dev/null "https://${PROXY_VHOST}:${PROXY_PORT}/probe" 2>/dev/null \
      | tr -d '\r' | awk 'tolower($0) ~ /^x-li-backend:/ {print $2; exit}' >>"$out" || echo fail >>"$out"
    i=$((i + 1))
  done
  sort -u "$out" | grep -v '^$' | grep -v '^fail$' || true
}

backends="$(unique_backends)"
n=$(echo "$backends" | grep -c . || echo 0)
echo "lb-e2e policy=${POLICY} distinct_backends=${n}"
echo "$backends" | sed 's/^/  backend: /'

case "$POLICY" in
  ip_hash)
    [ "$n" = "1" ] || { echo "FAIL ip_hash: expected 1 backend, got $n"; exit 1; }
    ;;
  round_robin|least_conn)
    [ "$n" -ge 2 ] || { echo "FAIL ${POLICY}: expected >=2 backends, got $n"; exit 1; }
    ;;
  *)
    echo "FAIL unknown LB_POLICY=$POLICY"
    exit 1
    ;;
esac

echo "PASS lb-e2e ${POLICY}"
