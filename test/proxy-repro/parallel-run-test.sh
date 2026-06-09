#!/bin/sh
# Parallel fetch of all sign_in CSS/JS through li-httpd — models browser load.
set -eu

HOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
PORT="${PROXY_PORT:-18443}"
PHOST="${PROXY_HOST:-127.0.0.1}"
RESOLVE="${CURL_RESOLVE:-${HOST}:${PORT}:${PHOST}}"
HTML=/tmp/proxy_repro_sign_in.html

curl -sk --http1.1 --resolve "$RESOLVE" -o "$HTML" --max-time 30 "https://${HOST}:${PORT}/users/sign_in"
grep -oE '(href|src)="(/assets/[^"]+)"' "$HTML" | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > /tmp/proxy_repro_assets.txt
n=$(wc -l < /tmp/proxy_repro_assets.txt)
tmpdir=$(mktemp -d)
results="$tmpdir/results.txt"
: > "$results"
pids=""
while IFS= read -r path; do
  (
    safe=$(echo "$path" | tr '/.' '__')
    out="$tmpdir/${safe}.body"
    hdr="$tmpdir/${safe}.hdr"
    meta=$(curl -sk --http1.1 --resolve "$RESOLVE" -D "$hdr" -o "$out" \
      -w '%{http_code} %{size_download}' --max-time 180 "https://${HOST}:${PORT}${path}" 2>/dev/null || echo '000 0')
    code=$(echo "$meta" | awk '{print $1}')
    dl=$(echo "$meta" | awk '{print $2}')
    clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
    first=$(head -c 1 "$out" 2>/dev/null | xxd -p || echo x)
    echo "$code $dl $clen $first $path" >> "$results"
  ) &
  pids="$pids $!"
done < /tmp/proxy_repro_assets.txt
for pid in $pids; do wait "$pid" || true; done
pass=0
fail=0
while read -r code dl clen first path; do
  ok=no
  [ "$code" = "200" ] && [ "$dl" = "$clen" ] && [ "$first" != "3c" ] && ok=yes
  if [ "$ok" = yes ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL $code $dl/$clen $path"; fi
done < "$results"
echo "RESULT parallel-container: ${pass}/${n}"
rm -rf "$tmpdir"
[ "$fail" -eq 0 ]
