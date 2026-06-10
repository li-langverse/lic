#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-$ROOT/results/latest-li-httpd}"
mkdir -p "$OUT"
COMPOSE="docker compose -f $ROOT/docker-compose.yml"
bash "$ROOT/gen-certs.sh" "$ROOT/certs"
$COMPOSE up -d backend
$COMPOSE --profile li-httpd up -d li-httpd --force-recreate
for i in $(seq 1 30); do
  if curl -sk --http1.1 --resolve gitlab.lilangverse.xyz:18443:127.0.0.1 \
    -o /dev/null --max-time 5 https://gitlab.lilangverse.xyz:18443/users/sign_in 2>/dev/null; then
    break
  fi
  sleep 2
done
export PROXY_HOST=127.0.0.1 PROXY_PORT=18443 PROXY_VHOST=gitlab.lilangverse.xyz
bash "$ROOT/sample-resources.sh" li-httpd 20 0.25 > "$OUT/resources-li-httpd.json" &
SP=$!
bash "$ROOT/workloads.sh" all li-httpd | tee "$OUT/workloads-li-httpd.jsonl" >> "$OUT/results.jsonl"
wait "$SP" || true
bash "$ROOT/sample-resources.sh" li-httpd 2 0.5 > "$OUT/resources-idle-li-httpd.json" || true
$COMPOSE --profile li-httpd stop li-httpd
python3 "$ROOT/parse-results.py" "$OUT"
cat "$OUT/RESULTS.md"
