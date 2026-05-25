#!/usr/bin/env bash
# gap-lb-sticky-sessions: ip_hash + cookie affinity on running build/li-httpd (multi-backend stickiness).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
CFG_IP="${STICKY_IP_HASH_CFG:-$ROOT/packages/li-net-httpd/examples/sticky_sessions.toml}"
CFG_COOKIE="${STICKY_COOKIE_CFG:-$ROOT/packages/li-net-httpd/examples/sticky_sessions_cookie.toml}"
CONF_IP="/tmp/httpd-sticky-ip.conf"
CONF_COOKIE="/tmp/httpd-sticky-cookie.conf"
BE1=18151
BE2=18152
PUBLIC_A="/tmp/httpd-sticky-peer-a"
PUBLIC_B="/tmp/httpd-sticky-peer-b"
PUBLIC_FRONT="$ROOT/packages/li-net-httpd/examples/public"
REQUESTS="${STICKY_SESSION_REQUESTS:-24}"

if [[ ! -x "$HTTPD" ]]; then
  echo "test-lb-sticky-sessions: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

mkdir -p "$PUBLIC_A" "$PUBLIC_B" "$PUBLIC_FRONT"
echo -n peer-a > "$PUBLIC_A/index.html"
echo -n peer-b > "$PUBLIC_B/index.html"

python3 "$ROOT/scripts/validate-httpd-config.py" "$CFG_IP"
python3 "$ROOT/scripts/validate-httpd-config.py" "$CFG_COOKIE"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$CFG_IP" -o "$CONF_IP"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$CFG_COOKIE" -o "$CONF_COOKIE"
grep -q '^upstream_balance=ip_hash' "$CONF_IP"
grep -q '^upstream_balance=cookie' "$CONF_COOKIE"
grep -q '^upstream_peer=18151' "$CONF_IP"
grep -q '^upstream_peer=18152' "$CONF_IP"

fuser -k "${BE1}/tcp" "${BE2}/tcp" 18140/tcp 18141/tcp 2>/dev/null || true
sleep 0.3

cleanup() {
  kill "${FE_IP_PID:-}" "${FE_COOKIE_PID:-}" "${BE1_PID:-}" "${BE2_PID:-}" 2>/dev/null || true
  wait "${FE_IP_PID:-}" "${FE_COOKIE_PID:-}" "${BE1_PID:-}" "${BE2_PID:-}" 2>/dev/null || true
}
trap cleanup EXIT

timeout 40 "$HTTPD" "$BE1" "$PUBLIC_A" >/dev/null 2>&1 &
BE1_PID=$!
timeout 40 "$HTTPD" "$BE2" "$PUBLIC_B" >/dev/null 2>&1 &
BE2_PID=$!
sleep 0.4

FRONT_IP="$(grep '^listen_port=' "$CONF_IP" | cut -d= -f2)"
FRONT_COOKIE="$(grep '^listen_port=' "$CONF_COOKIE" | cut -d= -f2)"

timeout 35 "$HTTPD" "$CONF_IP" >/dev/null 2>&1 &
FE_IP_PID=$!
timeout 35 "$HTTPD" "$CONF_COOKIE" >/dev/null 2>&1 &
FE_COOKIE_PID=$!
sleep 1.2

unique_bodies() {
  local url="$1"
  local jar="${2:-}"
  local out="/tmp/httpd-sticky-bodies-$$"
  : >"$out"
  local i
  for i in $(seq 1 "$REQUESTS"); do
    if [[ -n "$jar" ]]; then
      curl -s -m 3 -b "$jar" -c "$jar" "$url" >>"$out" || echo "curl_fail" >>"$out"
    else
      curl -s -m 3 "$url" >>"$out" || echo "curl_fail" >>"$out"
    fi
  done
  sort -u "$out" | grep -vc '^$' || true
}

# ip_hash: one client address -> one peer body (RR would alternate peer-a / peer-b).
n_ip="$(unique_bodies "http://127.0.0.1:${FRONT_IP}/")"
if [[ "$n_ip" != "1" ]]; then
  echo "test-lb-sticky-sessions: FAIL ip_hash expected 1 distinct body, got $n_ip" >&2
  exit 1
fi

# cookie: jar reuse pins backend after gateway Set-Cookie.
JAR="/tmp/httpd-sticky-cookie-$$.txt"
rm -f "$JAR"
n_cookie="$(unique_bodies "http://127.0.0.1:${FRONT_COOKIE}/" "$JAR")"
if [[ "$n_cookie" != "1" ]]; then
  echo "test-lb-sticky-sessions: FAIL cookie expected 1 distinct body, got $n_cookie" >&2
  exit 1
fi
if ! grep -q 'li_route' "$JAR" 2>/dev/null; then
  echo "test-lb-sticky-sessions: FAIL cookie jar missing li_route" >&2
  exit 1
fi

echo "test-lb-sticky-sessions: ok (ip_hash + cookie affinity, ${REQUESTS} requests each)"
