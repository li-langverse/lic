#!/usr/bin/env bash
# Run li-httpd workloads from tester container (avoids host port/TLS quirks).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
COMPOSE="docker compose -f $ROOT/docker-compose.yml"
OUT="${1:-$ROOT/results/20260609T203510Z}"
mkdir -p "$OUT"
$COMPOSE up -d backend
$COMPOSE --profile li-httpd up -d li-httpd
$COMPOSE --profile bench run -d --name proxy-comparison-tester-run tester \
  sh -c 'apk add --no-cache bash curl python3 >/dev/null && sleep infinity'
TESTER=proxy-comparison-tester-run
for i in $(seq 1 40); do
  if docker exec "$TESTER" curl -sk --http1.1 \
    --connect-to gitlab.lilangverse.xyz:8443:li-httpd:8443 \
    -o /dev/null --max-time 5 https://gitlab.lilangverse.xyz:8443/users/sign_in 2>/dev/null; then
    break
  fi
  sleep 2
done
docker cp "$ROOT/workloads.sh" "$TESTER:/workloads.sh"
docker exec "$TESTER" sh -c '
  export PROXY_HOST=li-httpd PROXY_PORT=8443 PROXY_VHOST=gitlab.lilangverse.xyz
  bash /workloads.sh all li-httpd
' | tee -a "$OUT/results.jsonl"
docker rm -f "$TESTER" 2>/dev/null || true
python3 "$ROOT/parse-results.py" "$OUT"
