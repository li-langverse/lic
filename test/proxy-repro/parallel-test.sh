#!/usr/bin/env bash
set -uo pipefail
HOST="${HOST:-gitlab.lilangverse.xyz}"
IP="${IP:-192.168.10.33}"
HTML="${HTML:-/tmp/gitlab_sign_in.html}"
RESOLVE="${HOST}:443:${IP}"

curl -sk --http1.1 --resolve "$RESOLVE" -o "$HTML" --max-time 30 "https://${HOST}/users/sign_in"
grep -oE '(href|src)="(/assets/[^"]+\.(css|js))"' "$HTML" | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > /tmp/gitlab_assets.txt
n=$(wc -l < /tmp/gitlab_assets.txt)
echo "=== parallel fetch $n assets ==="
tmpdir=$(mktemp -d)
results="$tmpdir/results.txt"
: > "$results"
pids=()
while IFS= read -r path; do
  (
    safe=$(echo "$path" | tr '/.' '__')
    out="$tmpdir/${safe}.body"
    hdr="$tmpdir/${safe}.hdr"
    meta=$(curl -sk --http1.1 --resolve "$RESOLVE" -D "$hdr" -o "$out" \
      -w '%{http_code} %{size_download}' --max-time 120 "https://${HOST}${path}" 2>/dev/null || echo '000 0')
    code=$(echo "$meta" | awk '{print $1}')
    dl=$(echo "$meta" | awk '{print $2}')
    clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
    first=$(head -c 1 "$out" 2>/dev/null | xxd -p || echo x)
    echo "$code $dl $clen $first $path" >> "$results"
  ) &
  pids+=($!)
done < /tmp/gitlab_assets.txt
for pid in "${pids[@]}"; do wait "$pid" || true; done
pass=0
fail=0
while read -r code dl clen first path; do
  ok=no
  [ "$code" = "200" ] && [ "$dl" = "$clen" ] && [ "$first" != "3c" ] && ok=yes
  if [ "$ok" = yes ]; then
    pass=$((pass+1))
  else
    fail=$((fail+1))
    echo "FAIL code=$code dl=$dl clen=$clen first=$first $path"
  fi
done < "$results"
echo "PARALLEL: $pass/$n ok fail=$fail"
rm -rf "$tmpdir"
