#!/bin/sh
set -eu
ENV_SH="/proxy-curl-env.sh"
[ -f "$ENV_SH" ] || ENV_SH="$(dirname "$0")/../proxy/proxy-curl-env.sh"
eval "$(sh "$ENV_SH")"
if [ "${PROXY_USE_CONNECT:-0}" = 1 ]; then
  PROXY_CURL="--connect-to ${PROXY_VHOST}:${PROXY_PORT}:${PROXY_CONNECT_HOST}:${PROXY_PORT}"
else
  PROXY_CURL="--resolve ${PROXY_RESOLVE}"
fi
HTML=/tmp/nextjs_index.html
curl -sk --http1.1 --no-keepalive $PROXY_CURL \
  -o "$HTML" --max-time 30 "https://${PROXY_VHOST}:${PROXY_PORT}/"
grep -oE '(href|src)="(/_next/static/[^"]+)"' "$HTML" | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > /tmp/nextjs_chunks.txt
n=$(wc -l < /tmp/nextjs_chunks.txt)
MIN_CHUNKS="${MIN_CHUNKS:-18}"
[ "$n" -ge "$MIN_CHUNKS" ] || { echo "FAIL chunk inventory: ${n} (need >= ${MIN_CHUNKS})"; exit 1; }
tmpdir=$(mktemp -d)
results="$tmpdir/results.txt"
: > "$results"
pids=""
while IFS= read -r path; do
  (
    safe=$(echo "$path" | tr '/.' '__')
    out="$tmpdir/${safe}.body"
    hdr="$tmpdir/${safe}.hdr"
    curl -sk --http1.1 --no-keepalive $PROXY_CURL \
      -D "$hdr" -o "$out" --max-time 180 "https://${PROXY_VHOST}:${PROXY_PORT}${path}" 2>/dev/null || true
    code=$(grep -m1 'HTTP/' "$hdr" 2>/dev/null | awk '{print $2}' || echo 000)
    clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
    wire=$(wc -c < "$out" 2>/dev/null | tr -d ' ')
    echo "$code $wire $clen $path" >> "$results"
  ) &
  pids="$pids $!"
done < /tmp/nextjs_chunks.txt
for pid in $pids; do wait "$pid" || true; done
pass=0
fail=0
while read -r code wire clen path; do
  if [ "$code" = "200" ] && [ -n "$clen" ] && [ "$wire" = "$clen" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL $code wire=$wire clen=$clen $path"
  fi
done < "$results"
echo "RESULT nextjs-parallel: ${pass}/${n}"
rm -rf "$tmpdir"
[ "$fail" -eq 0 ]
