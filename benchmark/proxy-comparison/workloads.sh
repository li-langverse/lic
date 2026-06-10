#!/usr/bin/env bash
# Workload runners — output JSON lines to stdout.
set -euo pipefail

VHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
PORT="${PROXY_PORT:?PROXY_PORT required}"
HOST="${PROXY_HOST:-127.0.0.1}"
CURL_EXTRA="${CURL_EXTRA:---http1.1 --no-keepalive -k}"

resolve_args() {
  case "$HOST" in
    *[!0-9.]*)
      echo "--connect-to ${VHOST}:${PORT}:${HOST}:${PORT}"
      ;;
    *)
      echo "--resolve ${VHOST}:${PORT}:${HOST}"
      ;;
  esac
}
PROXY_CURL=$(resolve_args)

curl_fetch() {
  local url="$1" out="$2" hdr="$3"
  : > "$hdr"
  : > "$out"
  curl -sk $CURL_EXTRA $PROXY_CURL -D "$hdr" -o "$out" \
    -w '%{http_code} %{time_total} %{size_download}' \
    --max-time 60 "https://${VHOST}:${PORT}${url}" 2>/dev/null || echo '000 0 0'
}

verify_body() {
  local hdr="$1" body="$2"
  local code clen wire
  code=$(grep -m1 'HTTP/' "$hdr" 2>/dev/null | awk '{print $2}' || echo 000)
  clen=$(grep -i '^content-length:' "$hdr" 2>/dev/null | tail -1 | awk '{print $2}' | tr -d '\r')
  if [ -f "$body" ]; then wire=$(wc -c < "$body" | tr -d ' '); else wire=0; fi
  local ok=0
  [ "$code" = "200" ] && [ -n "$clen" ] && [ "$wire" = "$clen" ] && ok=1
  echo "$code $wire $clen $ok"
}

emit_result() {
  local workload="$1" proxy="$2" n="$3" pass="$4" total_bytes="$5" elapsed="$6"
  python3 - "$workload" "$proxy" "$n" "$pass" "$total_bytes" "$elapsed" "${LATENCIES[@]:-}" <<'PY'
import json, sys
workload, proxy, n, passed, total_bytes, elapsed = sys.argv[1:7]
lat = [float(x) for x in sys.argv[7:]]
lat.sort()
def pct(p):
    if not lat: return 0.0
    i = max(0, min(len(lat)-1, int(round(p/100*(len(lat)-1)))))
    return lat[i]
out = {
    "workload": workload,
    "proxy": proxy,
    "requests": int(n),
    "success": int(passed),
    "success_rate": round(int(passed)/max(1,int(n)), 4),
    "total_bytes": int(total_bytes),
    "elapsed_s": float(elapsed),
    "rps": round(int(n)/max(0.001,float(elapsed)), 2),
    "bps": round(int(total_bytes)/max(0.001,float(elapsed)), 0),
    "latency_p50": round(pct(50), 4),
    "latency_p95": round(pct(95), 4),
    "latency_p99": round(pct(99), 4),
}
print(json.dumps(out))
PY
}

# 1) Sequential single 1.3MB asset
workload_sequential() {
  local proxy="$1"
  local asset="/assets/webpack/main.deadbeef.chunk.js"
  local expected=1321365
  local tmpdir hdr body meta
  tmpdir=$(mktemp -d)
  hdr="$tmpdir/h.hdr" body="$tmpdir/h.body"
  local t0 t1
  t0=$(date +%s.%N)
  meta=$(curl_fetch "$asset" "$body" "$hdr")
  t1=$(date +%s.%N)
  local code t dl
  read -r code t dl <<< "$meta"
  local v ok=0 wire=0
  if [ -f "$body" ] && [ -f "$hdr" ]; then
    v=$(verify_body "$hdr" "$body")
  else
    v="000 0 0 0"
  fi
  local vcode clen
  read -r vcode wire clen ok <<< "$v"
  LATENCIES=("$t")
  local elapsed
  elapsed=$(python3 -c "print(round(float('$t1')-float('$t0'),4))")
  emit_result "sequential_1p3mb" "$proxy" 1 "$ok" "${wire:-0}" "$elapsed"
  rm -rf "$tmpdir"
}

# 2) Parallel 18 assets from sign_in HTML
workload_parallel18() {
  local proxy="$1"
  local tmpdir html assets results
  tmpdir=$(mktemp -d)
  html="$tmpdir/sign_in.html"
  assets="$tmpdir/assets.txt"
  results="$tmpdir/results.txt"
  curl -sk $CURL_EXTRA $PROXY_CURL -o "$html" --max-time 30 \
    "https://${VHOST}:${PORT}/users/sign_in"
  grep -oE '(href|src)="(/assets/[^"]+)"' "$html" \
    | sed -E 's/.*="([^"]+)".*/\1/' | sort -u > "$assets"
  local n; n=$(wc -l < "$assets")
  : > "$results"
  local pids="" t0 t1
  t0=$(date +%s.%N)
  while IFS= read -r path; do
    (
      safe=$(echo "$path" | tr '/.' '__')
      out="$tmpdir/${safe}.body"
      hdr="$tmpdir/${safe}.hdr"
      meta=$(curl_fetch "$path" "$out" "$hdr")
      code=$(echo "$meta" | awk '{print $1}')
      t=$(echo "$meta" | awk '{print $2}')
      v=$(verify_body "$hdr" "$out")
      vcode=$(echo "$v" | awk '{print $1}')
      wire=$(echo "$v" | awk '{print $2}')
      clen=$(echo "$v" | awk '{print $3}')
      ok=$(echo "$v" | awk '{print $4}')
      echo "${code}|${t}|${wire}|${clen}|${ok}" >> "$results"
    ) &
    pids="$pids $!"
  done < "$assets"
  for pid in $pids; do wait "$pid" || true; done
  t1=$(date +%s.%N)
  local pass=0 total_bytes=0
  LATENCIES=()
  while IFS='|' read -r code t wire clen ok; do
    [ "$ok" = "1" ] && pass=$((pass + 1))
    total_bytes=$((total_bytes + wire))
    LATENCIES+=("$t")
  done < "$results"
  local elapsed
  elapsed=$(python3 -c "print(round(float('$t1')-float('$t0'),4))")
  emit_result "parallel_18" "$proxy" "$n" "$pass" "$total_bytes" "$elapsed"
  rm -rf "$tmpdir"
}

# 3) Parallel 6 same large asset
workload_parallel6() {
  local proxy="$1"
  local asset="/assets/webpack/main.deadbeef.chunk.js"
  local n=6
  local tmpdir results
  tmpdir=$(mktemp -d)
  results="$tmpdir/results.txt"
  : > "$results"
  local pids="" t0 t1
  t0=$(date +%s.%N)
  local i=1
  while [ "$i" -le "$n" ]; do
    (
      out="$tmpdir/body_$i"
      hdr="$tmpdir/hdr_$i"
      meta=$(curl_fetch "$asset" "$out" "$hdr")
      code=$(echo "$meta" | awk '{print $1}')
      t=$(echo "$meta" | awk '{print $2}')
      v=$(verify_body "$hdr" "$out")
      vcode=$(echo "$v" | awk '{print $1}')
      wire=$(echo "$v" | awk '{print $2}')
      clen=$(echo "$v" | awk '{print $3}')
      ok=$(echo "$v" | awk '{print $4}')
      echo "${code}|${t}|${wire}|${clen}|${ok}" >> "$results"
    ) &
    pids="$pids $!"
    i=$((i + 1))
  done
  for pid in $pids; do wait "$pid" || true; done
  t1=$(date +%s.%N)
  local pass=0 total_bytes=0
  LATENCIES=()
  while IFS='|' read -r code t wire clen ok; do
    [ "$ok" = "1" ] && pass=$((pass + 1))
    total_bytes=$((total_bytes + wire))
    LATENCIES+=("$t")
  done < "$results"
  local elapsed
  elapsed=$(python3 -c "print(round(float('$t1')-float('$t0'),4))")
  emit_result "parallel_6_same" "$proxy" "$n" "$pass" "$total_bytes" "$elapsed"
  rm -rf "$tmpdir"
}

# 4) Small + large mix (84B + 835KB)
workload_mix_small_large() {
  local proxy="$1"
  local paths=("/assets/utilities-deadbeef.css" "/assets/application-deadbeef.css")
  local n=${#paths[@]}
  local tmpdir results
  tmpdir=$(mktemp -d)
  results="$tmpdir/results.txt"
  : > "$results"
  local pids="" t0 t1
  t0=$(date +%s.%N)
  for path in "${paths[@]}"; do
    (
      safe=$(echo "$path" | tr '/.' '__')
      out="$tmpdir/${safe}.body"
      hdr="$tmpdir/${safe}.hdr"
      meta=$(curl_fetch "$path" "$out" "$hdr")
      code=$(echo "$meta" | awk '{print $1}')
      t=$(echo "$meta" | awk '{print $2}')
      v=$(verify_body "$hdr" "$out")
      vcode=$(echo "$v" | awk '{print $1}')
      wire=$(echo "$v" | awk '{print $2}')
      clen=$(echo "$v" | awk '{print $3}')
      ok=$(echo "$v" | awk '{print $4}')
      echo "${code}|${t}|${wire}|${clen}|${ok}" >> "$results"
    ) &
    pids="$pids $!"
  done
  for pid in $pids; do wait "$pid" || true; done
  t1=$(date +%s.%N)
  local pass=0 total_bytes=0
  LATENCIES=()
  while IFS='|' read -r code t wire clen ok; do
    [ "$ok" = "1" ] && pass=$((pass + 1))
    total_bytes=$((total_bytes + wire))
    LATENCIES+=("$t")
  done < "$results"
  local elapsed
  elapsed=$(python3 -c "print(round(float('$t1')-float('$t0'),4))")
  emit_result "mix_small_large" "$proxy" "$n" "$pass" "$total_bytes" "$elapsed"
  rm -rf "$tmpdir"
}

case "${1:-}" in
  sequential_1p3mb) workload_sequential "${2:?proxy}" ;;
  parallel_18) workload_parallel18 "${2:?proxy}" ;;
  parallel_6_same) workload_parallel6 "${2:?proxy}" ;;
  mix_small_large) workload_mix_small_large "${2:?proxy}" ;;
  all)
    proxy="${2:?proxy}"
    workload_sequential "$proxy"
    workload_parallel18 "$proxy"
    workload_parallel6 "$proxy"
    workload_mix_small_large "$proxy"
    ;;
  *) echo "usage: $0 {sequential_1p3mb|parallel_18|parallel_6_same|mix_small_large|all} PROXY" >&2; exit 1 ;;
esac
