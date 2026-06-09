#!/bin/sh
# GitLab sign_in HTML + 18 parallel asset wc -c gate through li-httpd TLS proxy.
set -eu

ENV_SH="/proxy-curl-env.sh"
[ -f "$ENV_SH" ] || ENV_SH="$(dirname "$0")/../../proxy/proxy-curl-env.sh"
eval "$(sh "$ENV_SH")"
if [ "${PROXY_USE_CONNECT:-0}" = 1 ]; then
  PROXY_CURL="--connect-to ${PROXY_VHOST}:${PROXY_PORT}:${PROXY_CONNECT_HOST}:${PROXY_PORT}"
else
  PROXY_CURL="--resolve ${PROXY_RESOLVE}"
fi
MIN_ASSETS="${MIN_ASSETS:-18}"
CURL_EXTRA="${CURL_EXTRA:---http1.1 --no-keepalive --tls-max 1.2}"

HTML=/tmp/gitlab_sign_in.html
curl -sk $CURL_EXTRA $PROXY_CURL -o "$HTML" --max-time 30 \
  "https://${PROXY_VHOST}:${PROXY_PORT}/users/sign_in"

grep -qi 'stylesheet' "$HTML" || { echo "FAIL sign_in HTML missing stylesheets"; exit 1; }

grep -oE '(href|src)="(/assets/[^"]+)"' "$HTML" | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > /tmp/gitlab_assets.txt
n=$(wc -l < /tmp/gitlab_assets.txt)
[ "$n" -ge "$MIN_ASSETS" ] || { echo "FAIL asset inventory: ${n} (need >= ${MIN_ASSETS})"; exit 1; }

tmpdir=$(mktemp -d)
results="$tmpdir/results.txt"
: > "$results"
pids=""
while IFS= read -r path; do
  (
    safe=$(echo "$path" | tr '/.' '__')
    out="$tmpdir/${safe}.body"
    hdr="$tmpdir/${safe}.hdr"
    curl -sk $CURL_EXTRA $PROXY_CURL -D "$hdr" -o "$out" \
      --max-time 180 "https://${PROXY_VHOST}:${PROXY_PORT}${path}" 2>/dev/null || true
    code=$(grep -m1 'HTTP/' "$hdr" 2>/dev/null | awk '{print $2}' || echo 000)
    clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
    wire=$(wc -c < "$out" 2>/dev/null | tr -d ' ')
    echo "$code $wire $clen $path" >> "$results"
  ) &
  pids="$pids $!"
done < /tmp/gitlab_assets.txt
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
echo "RESULT gitlab-parallel: ${pass}/${n}"
rm -rf "$tmpdir"
[ "$fail" -eq 0 ]
