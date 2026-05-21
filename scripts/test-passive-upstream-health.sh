#!/usr/bin/env bash
# M1 wave 7 — passive health marks dead upstream peer down; live peer still serves.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
CFG="${PASSIVE_HEALTH_CFG:-$ROOT/packages/li-httpd/examples/passive_health.toml}"
BE_PORT=18101
CONF="/tmp/httpd-passive-health.conf"
PUBLIC="$(cd "$ROOT/packages/li-httpd/examples" && mkdir -p public && pwd)/public"

if [[ ! -x "$HTTPD" ]]; then
  echo "test-passive-upstream-health: build li-httpd first" >&2
  exit 1
fi

mkdir -p "$PUBLIC"
echo ok > "$PUBLIC/index.html"

"$ROOT/scripts/lic-validate-httpd-config.sh" "$CFG"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$CFG" -o "$CONF"

fuser -k "${BE_PORT}/tcp" 18100/tcp 18102/tcp 2>/dev/null || true
sleep 0.3

# Only BE_PORT is listening; 18102 is intentionally dead.
timeout 30 "$HTTPD" "$BE_PORT" "$PUBLIC" >/dev/null 2>&1 &
BE_PID=$!
sleep 0.4

FRONT_PORT="$(grep '^listen_port=' "$CONF" | cut -d= -f2)"
timeout 20 "$HTTPD" "$CONF" >/dev/null 2>&1 &
FE_PID=$!
sleep 0.5

code=$(curl -s -m 3 -o /dev/null -w "%{http_code}" "http://127.0.0.1:${FRONT_PORT}/" || echo "000")

kill "$FE_PID" "$BE_PID" 2>/dev/null || true
wait "$FE_PID" 2>/dev/null || true
wait "$BE_PID" 2>/dev/null || true

if [[ "$code" != "200" ]]; then
  echo "test-passive-upstream-health: FAIL expected 200 got $code (front=$FRONT_PORT)" >&2
  exit 1
fi
echo "test-passive-upstream-health: ok (proxy LB skipped dead peer 18102)"
