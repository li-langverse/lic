#!/bin/sh
# Hammer gate: N parallel asset fetches, 3 consecutive rounds without process restart.
set -eu
HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-18443}"
VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
MIN_ASSETS="${HAMMER_MIN_ASSETS:-6}"
ROUNDS="${HAMMER_ROUNDS:-3}"
USE_CONNECT_TO=0
RESOLVE=""
case "$HOST" in
  *[!0-9.]*)
    USE_CONNECT_TO=1
    ;;
  *)
    RESOLVE="${VHOST}:${PORT}:${HOST}"
    ;;
esac
HTML=/tmp/proxy_hammer_sign_in.html
ASSETS=/tmp/proxy_hammer_assets.txt
CURL_EXTRA="${CURL_EXTRA:---http1.1 --no-keepalive --tls-max 1.2}"

if [ "$USE_CONNECT_TO" -eq 1 ]; then
  curl -sk $CURL_EXTRA --connect-to "${VHOST}:${PORT}:${HOST}:${PORT}" -o "$HTML" --max-time 30 \
    "https://${VHOST}:${PORT}/users/sign_in"
else
  curl -sk $CURL_EXTRA --resolve "$RESOLVE" -o "$HTML" --max-time 30 \
    "https://${VHOST}:${PORT}/users/sign_in"
fi
grep -oE '(href|src)="(/assets/[^"]+\.(css|js))"' "$HTML" \
  | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > "$ASSETS"
n=$(wc -l < "$ASSETS")
[ "$n" -ge "$MIN_ASSETS" ] || { echo "FAIL hammer asset inventory: ${n} < ${MIN_ASSETS}"; exit 1; }

round=1
while [ "$round" -le "$ROUNDS" ]; do
  echo "== hammer round ${round}/${ROUNDS} (${n} assets) =="
  tmpdir=$(mktemp -d)
  pids=""
  while IFS= read -r path; do
    (
      safe=$(printf '%s' "$path" | md5sum | awk '{print $1}')
      out="$tmpdir/${safe}.body"
      hdr="$tmpdir/${safe}.hdr"
      res="$tmpdir/${safe}.result"
      if [ "$USE_CONNECT_TO" -eq 1 ]; then
        curl -sk $CURL_EXTRA --connect-to "${VHOST}:${PORT}:${HOST}:${PORT}" -D "$hdr" -o "$out" \
          --max-time 180 "https://${VHOST}:${PORT}${path}" 2>/dev/null || true
      else
        curl -sk $CURL_EXTRA --resolve "$RESOLVE" -D "$hdr" -o "$out" \
          --max-time 180 "https://${VHOST}:${PORT}${path}" 2>/dev/null || true
      fi
      code=$(grep -m1 'HTTP/' "$hdr" 2>/dev/null | awk '{print $2}' || echo 000)
      clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
      wire=0
      if [ -f "$out" ]; then
        wire=$(wc -c < "$out" | tr -d ' ')
      fi
      echo "${code}|${wire}|${clen}|${path}" > "$res"
    ) &
    pids="$pids $!"
  done < "$ASSETS"
  for pid in $pids; do wait "$pid" || true; done
  pass=0
  fail=0
  for res in "$tmpdir"/*.result; do
    [ -f "$res" ] || continue
    IFS='|' read -r code wire clen path < "$res" || true
    if [ "$code" = "200" ] && [ -n "$clen" ] && [ "$wire" = "$clen" ]; then
      pass=$((pass + 1))
    else
      fail=$((fail + 1))
      echo "FAIL round=${round} $code wire=$wire clen=$clen $path"
    fi
  done
  rm -rf "$tmpdir"
  [ "$fail" -eq 0 ] || { echo "FAIL parallel_hammer_3x round=${round}: ${pass}/${n}"; exit 1; }
  echo "PASS round ${round}: ${pass}/${n}"
  round=$((round + 1))
done
echo "RESULT parallel-hammer-3x: ${ROUNDS}/${ROUNDS} rounds ${n}/${n}"
