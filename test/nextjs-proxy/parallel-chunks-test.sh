#!/bin/sh
set -eu
HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-19443}"
VHOST="${PROXY_VHOST:-nextjs.test}"
CONNECT_TO=""
RESOLVE=""
case "$HOST" in
  *[!0-9.]*)
    CONNECT_TO="--connect-to ${VHOST}:${PORT}:${HOST}:${PORT}"
    ;;
  *)
    RESOLVE="${VHOST}:${PORT}:${HOST}"
    ;;
esac
HTML=/tmp/nextjs_index.html
curl -sk --http1.1 --no-keepalive $CONNECT_TO ${RESOLVE:+--resolve "$RESOLVE"} \
  -o "$HTML" --max-time 30 "https://${VHOST}:${PORT}/"
grep -oE '(href|src)="(/_next/static/[^"]+)"' "$HTML" | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > /tmp/nextjs_chunks.txt
n=$(wc -l < /tmp/nextjs_chunks.txt)
tmpdir=$(mktemp -d)
results="$tmpdir/results.txt"
: > "$results"
pids=""
while IFS= read -r path; do
  (
    safe=$(echo "$path" | tr '/.' '__')
    out="$tmpdir/${safe}.body"
    hdr="$tmpdir/${safe}.hdr"
    curl -sk --http1.1 --no-keepalive $CONNECT_TO ${RESOLVE:+--resolve "$RESOLVE"} \
      -D "$hdr" -o "$out" --max-time 180 "https://${VHOST}:${PORT}${path}" 2>/dev/null || true
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
