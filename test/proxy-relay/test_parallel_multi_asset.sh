#!/bin/sh
# 18 parallel CSS+JS fetches - browser-like GitLab sign_in load.
set -eu

HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-18443}"
VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
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
HTML=/tmp/proxy_relay_sign_in.html
CURL_EXTRA="${CURL_EXTRA:---http1.1 --no-keepalive}"

curl -sk $CURL_EXTRA $CONNECT_TO ${RESOLVE:+--resolve "$RESOLVE"} -o "$HTML" --max-time 30 \
  "https://${VHOST}:${PORT}/users/sign_in"
grep -oE '(href|src)="(/assets/[^"]+)"' "$HTML" | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > /tmp/proxy_relay_assets.txt
n=$(wc -l < /tmp/proxy_relay_assets.txt)
[ "$n" -ge 6 ] || { echo "FAIL asset inventory: ${n} paths"; exit 1; }

tmpdir=$(mktemp -d)
results="$tmpdir/results.txt"
: > "$results"
pids=""
while IFS= read -r path; do
  (
    safe=$(echo "$path" | tr '/.' '__')
    out="$tmpdir/${safe}.body"
    hdr="$tmpdir/${safe}.hdr"
    curl -sk $CURL_EXTRA $CONNECT_TO ${RESOLVE:+--resolve "$RESOLVE"} -D "$hdr" -o "$out" \
      --max-time 180 "https://${VHOST}:${PORT}${path}" 2>/dev/null || true
    code=$(grep -m1 'HTTP/' "$hdr" 2>/dev/null | awk '{print $2}' || echo 000)
    clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
    wire=$(wc -c < "$out" 2>/dev/null | tr -d ' ')
    echo "$code $wire $clen $path" >> "$results"
  ) &
  pids="$pids $!"
done < /tmp/proxy_relay_assets.txt
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
echo "RESULT parallel-multi: ${pass}/${n}"
rm -rf "$tmpdir"
[ "$fail" -eq 0 ]
