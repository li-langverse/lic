#!/usr/bin/env bash
# M1 wave 6 — per-route limit on GET /api/* returns 429 under burst; GET / unaffected.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
CFG_EX="${RATE_LIMIT_PER_ROUTE_CFG:-$ROOT/packages/li-httpd/examples/rate_limit_per_route.toml}"
PUBLIC="$(cd "$ROOT/packages/li-httpd/examples" && mkdir -p public && pwd)/public"
CONF="/tmp/httpd-rate-limit-route-test.conf"

if [[ ! -x "$HTTPD" ]]; then
  echo "test-rate-limit-per-route: build li-httpd first" >&2
  exit 1
fi

mkdir -p "$PUBLIC/api"
echo api > "$PUBLIC/api/index.html"
echo root > "$PUBLIC/index.html"

python3 "$ROOT/scripts/flatten-httpd-config.py" "$CFG_EX" -o "$CONF"
PORT="$(grep '^listen_port=' "$CONF" | cut -d= -f2)"
fuser -k "${PORT}/tcp" 2>/dev/null || true
sleep 0.3

timeout 12 "$HTTPD" "$CONF" >/dev/null 2>&1 &
SRV_PID=$!
sleep 0.5

got429=0
ok_root=0
for _ in $(seq 1 25); do
  code=$(curl -s -m 1 -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PORT}/api/" || echo "000")
  if [[ "$code" == "429" ]]; then
    got429=1
    break
  fi
done
code_root=$(curl -s -m 1 -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PORT}/index.html" || echo "000")
[[ "$code_root" == "200" ]] && ok_root=1

kill "$SRV_PID" 2>/dev/null || true
wait "$SRV_PID" 2>/dev/null || true

if [[ "$got429" != "1" || "$ok_root" != "1" ]]; then
  echo "test-rate-limit-per-route: FAIL got429=$got429 ok_root=$ok_root port=$PORT" >&2
  exit 1
fi
echo "test-rate-limit-per-route: ok (429 on /api/, 200 on /)"
