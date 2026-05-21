#!/usr/bin/env bash
# M1 wave 4 — verify global rate limit returns HTTP 429 under burst load.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
CFG_EX="${RATE_LIMIT_CFG:-$ROOT/packages/li-httpd/examples/rate_limit_static.toml}"
PUBLIC="$(cd "$ROOT/packages/li-httpd/examples" && mkdir -p public && pwd)/public"
CONF="/tmp/httpd-rate-limit-test.conf"

if [[ ! -x "$HTTPD" ]]; then
  echo "test-rate-limit-429: build li-httpd first (LI_HTTPD_BIN=$HTTPD)" >&2
  exit 1
fi

mkdir -p "$PUBLIC"
echo ok > "$PUBLIC/index.html"

python3 "$ROOT/scripts/validate-httpd-config.py" "$CFG_EX"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$CFG_EX" -o "$CONF"

PORT="$(grep '^listen_port=' "$CONF" | cut -d= -f2)"
fuser -k "${PORT}/tcp" 2>/dev/null || true
sleep 0.3

timeout 12 "$HTTPD" "$CONF" >/dev/null 2>&1 &
SRV_PID=$!
sleep 0.5

got429=0
for _ in $(seq 1 30); do
  code=$(curl -s -m 1 -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PORT}/" || echo "000")
  if [[ "$code" == "429" ]]; then
    got429=1
    break
  fi
done

kill "$SRV_PID" 2>/dev/null || true
wait "$SRV_PID" 2>/dev/null || true

if [[ "$got429" != "1" ]]; then
  echo "test-rate-limit-429: FAIL — no 429 in 30 rapid requests (port=$PORT)" >&2
  exit 1
fi
echo "test-rate-limit-429: ok (saw HTTP 429 on port $PORT)"
