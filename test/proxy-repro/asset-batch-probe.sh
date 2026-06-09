#!/usr/bin/env bash
# Batch-probe all CSS/JS assets from GitLab sign_in via edge vs NodePort.
set -uo pipefail

HOST="${HOST:-gitlab.lilangverse.xyz}"
EDGE_RESOLVE="${EDGE_RESOLVE:-${HOST}:443:127.0.0.1}"
NODEPORT="${NODEPORT:-127.0.0.1:30481}"
RUNS="${RUNS:-3}"
HTML_OUT="${HTML_OUT:-/tmp/gitlab_sign_in.html}"
REPORT="${REPORT:-/tmp/gitlab_asset_probe.txt}"

probe_one() {
  local label=$1 url=$2 expected=$3
  local pass=0 run code clen dl ctype first last
  for run in $(seq 1 "$RUNS"); do
    local tmp=/tmp/probe_$$
    local meta
    meta=$(curl -sS -k --http1.1 --no-keepalive --resolve "$EDGE_RESOLVE" \
      -D "$tmp.hdr" -o "$tmp.body" -w '%{http_code} %{size_download} %{content_type}' \
      --max-time 120 "https://${HOST}${url}" 2>/dev/null || echo '000 0 -')
    code=$(echo "$meta" | awk '{print $1}')
    dl=$(echo "$meta" | awk '{print $2}')
    ctype=$(echo "$meta" | cut -d' ' -f3-)
    clen=$(grep -i '^content-length:' "$tmp.hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
    first=$(head -c 4 "$tmp.body" 2>/dev/null | xxd -p 2>/dev/null || echo none)
    last=$(tail -c 4 "$tmp.body" 2>/dev/null | xxd -p 2>/dev/null || echo none)
    rm -f "$tmp.hdr" "$tmp.body"
    local ok=no
    if [ "$code" = "200" ]; then
      if [ -n "$expected" ] && [ "$expected" != "0" ]; then
        [ "$dl" = "$expected" ] && ok=yes
      else
        [ -n "$clen" ] && [ "$dl" = "$clen" ] && ok=yes
      fi
    fi
    [ "$ok" = yes ] && pass=$((pass + 1))
    echo "  edge run${run}: code=${code} clen=${clen:-?} dl=${dl} ctype=${ctype} first=${first} last=${last} ok=${ok}"
  done
  echo "  edge PASS=${pass}/${RUNS}"
}

probe_nodeport() {
  local url=$1
  local meta
  meta=$(curl -sS --http1.1 --no-keepalive -H "Host: ${HOST}" \
    -o /dev/null -w '%{http_code} %{size_download}' \
    --max-time 120 "http://${NODEPORT}${url}" 2>/dev/null || echo '000 0')
  echo "  nodeport: code=$(echo "$meta" | awk '{print $1}') dl=$(echo "$meta" | awk '{print $2}')"
}

echo "=== Fetch sign_in HTML ===" | tee "$REPORT"
curl -sS -k --http1.1 --resolve "$EDGE_RESOLVE" --max-time 30 \
  "https://${HOST}/users/sign_in" -o "$HTML_OUT"
wc -c "$HTML_OUT" | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "=== Asset inventory ===" | tee -a "$REPORT"
# Extract href/src paths
grep -oE '<(link|script)[^>]+(href|src)="[^"]+"' "$HTML_OUT" | \
  sed -E 's/.*(href|src)="([^"]+)".*/\2/' | sort -u | tee /tmp/gitlab_assets.txt

css_urls=$(grep -E '\.css' /tmp/gitlab_assets.txt || true)
js_urls=$(grep -E '\.js' /tmp/gitlab_assets.txt || true)

echo "" | tee -a "$REPORT"
echo "=== CSS probes (edge ${RUNS}x) ===" | tee -a "$REPORT"
for url in $css_urls; do
  echo "CSS ${url}" | tee -a "$REPORT"
  probe_one edge "$url" "" | tee -a "$REPORT"
  probe_nodeport "$url" | tee -a "$REPORT"
done

echo "" | tee -a "$REPORT"
echo "=== JS probes (edge ${RUNS}x) ===" | tee -a "$REPORT"
for url in $js_urls; do
  echo "JS ${url}" | tee -a "$REPORT"
  probe_one edge "$url" "" | tee -a "$REPORT"
  probe_nodeport "$url" | tee -a "$REPORT"
done

echo "" | tee -a "$REPORT"
echo "=== DONE report=${REPORT} ===" | tee -a "$REPORT"
