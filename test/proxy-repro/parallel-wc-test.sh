#!/bin/sh
# Parallel asset fetch with wc -c verification (not size_download).
set -eu

HOST="${PROXY_HOST:-127.0.0.1}"
PORT="${PROXY_PORT:-18443}"
VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
N="${PARALLEL_N:-6}"
ASSET="${PARALLEL_ASSET:-/assets/webpack/main.deadbeef.chunk.js}"
EXPECTED="${EXPECTED_BYTES:-1321365}"
CURL_EXTRA="${CURL_EXTRA:---tls-max 1.2}"
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

tmpdir=$(mktemp -d)
results="$tmpdir/results.txt"
: > "$results"
pids=""
i=1
while [ "$i" -le "$N" ]; do
  (
    out="$tmpdir/body_$i"
    hdr="$tmpdir/hdr_$i"
    curl -sk $CURL_EXTRA --http1.1 $CONNECT_TO ${RESOLVE:+--resolve "$RESOLVE"} -D "$hdr" -o "$out" \
      -w '%{http_code}' --max-time 180 "https://${VHOST}:${PORT}${ASSET}" > "$tmpdir/code_$i" 2>/dev/null || echo 000 > "$tmpdir/code_$i"
    code=$(cat "$tmpdir/code_$i")
    clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
    wire=$(wc -c < "$out" | tr -d ' ')
    echo "$code $wire $clen" >> "$results"
  ) &
  pids="$pids $!"
  i=$((i + 1))
done
for pid in $pids; do wait "$pid" || true; done

pass=0
fail=0
while read -r code wire clen; do
  if [ "$code" = "200" ] && [ -n "$clen" ] && [ "$wire" = "$clen" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL code=$code wire=$wire clen=$clen"
  fi
done < "$results"
echo "RESULT parallel-same: ${pass}/${N} expected_cl=${EXPECTED}"
rm -rf "$tmpdir"
[ "$fail" -eq 0 ]
