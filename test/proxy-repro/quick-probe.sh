#!/bin/sh
set -eu
HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-18443}"
VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
RESOLVE="${VHOST}:${PORT}:${HOST}"
echo "probe RESOLVE=$RESOLVE"
code=$(curl -sk --http1.1 --resolve "$RESOLVE" -o /dev/null -w '%{http_code}' --max-time 15 "https://${VHOST}:${PORT}/users/sign_in" || echo 000)
echo "sign_in code=$code"
out=/tmp/probe_large.js
hdr=/tmp/probe_large.hdr
curl -sk --http1.1 --resolve "$RESOLVE" -D "$hdr" -o "$out" --max-time 120 "https://${VHOST}:${PORT}/assets/webpack/main.deadbeef.chunk.js" || true
clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
wire=$(wc -c < "$out" | tr -d ' ')
echo "large_js clen=$clen wire=$wire"
[ "$clen" = "$wire" ] && echo OK || echo FAIL
