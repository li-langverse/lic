#!/bin/sh
set -eu
HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-18443}"
VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
RUNS="${RUNS:-5}"
ASSET="${ASSET:-/assets/webpack/main.deadbeef.chunk.js}"
RESOLVE="${VHOST}:${PORT}:${HOST}"
pass=0
i=1
while [ "$i" -le "$RUNS" ]; do
  out="/tmp/seq_wc_${i}.body"
  hdr="/tmp/seq_wc_${i}.hdr"
  code=$(curl -sk --tls-max "${TLS_MAX:-1.2}" --http1.1 --no-keepalive --resolve "$RESOLVE" \
    -D "$hdr" -o "$out" -w '%{http_code}' --max-time 120 \
    "https://${VHOST}:${PORT}${ASSET}" 2>/dev/null || echo 000)
  clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
  wire=$(wc -c < "$out" | tr -d ' ')
  ok=no
  [ "$code" = "200" ] && [ -n "$clen" ] && [ "$wire" = "$clen" ] && ok=yes
  [ "$ok" = yes ] && pass=$((pass + 1))
  echo "run $i: code=$code wire=$wire clen=$clen ok=$ok"
  i=$((i + 1))
done
echo "RESULT sequential-wc: ${pass}/${RUNS}"
[ "$pass" -eq "$RUNS" ]
