#!/usr/bin/env bash
# TLS 1.2 DHE handshake on live li-httpd when dhparam is configured.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
CFG="${TLS_DHE_CFG:-$ROOT/packages/li-net-httpd/examples/tls_dhe.toml}"
CONF="/tmp/httpd-tls-dhe.conf"
CERT_DIR="/tmp/httpd-tls-dhe-certs"
PUBLIC="/tmp/httpd-tls-dhe-public"
PORT=18446

if [[ ! -x "$HTTPD" ]]; then
  echo "check-httpd-tls-dhe: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

if [[ ! -f "$CFG" ]]; then
  echo "check-httpd-tls-dhe: missing config $CFG" >&2
  exit 1
fi

mkdir -p "$PUBLIC" "$CERT_DIR"
echo ok > "$PUBLIC/health"

python3 "$ROOT/scripts/validate-httpd-config.py" "$CFG"
python3 "$ROOT/scripts/setup-tls-httpd.py" "$CFG" --cert-dir "$CERT_DIR"
if [[ ! -f "$CERT_DIR/dhparam.pem" ]]; then
  openssl dhparam -out "$CERT_DIR/dhparam.pem" 2048
fi
python3 "$ROOT/scripts/flatten-httpd-config.py" "$CFG" -o "$CONF" --cert-dir "$CERT_DIR"
grep -q '^tls_enabled=1' "$CONF"
grep -q '^tls_dhparam_file=' "$CONF"

fuser -k "${PORT}/tcp" 2>/dev/null || true
sleep 0.3

LI_HTTPD_WORKERS=1 "$HTTPD" "$CONF" >/dev/null 2>&1 &
FE_PID=$!
sleep 1.2

fail=0
blob="$(echo | timeout 8 openssl s_client \
  -connect "127.0.0.1:${PORT}" \
  -servername localhost \
  -tls1_2 \
  -cipher 'ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384' \
  2>/dev/null || true)"

if ! grep -qiE 'Cipher\s*:\s*DHE|Cipher is DHE|New, TLSv1.2' <<<"$blob"; then
  echo "check-httpd-tls-dhe: FAIL expected TLS1.2 DHE cipher in handshake" >&2
  echo "${blob:0:400}" >&2
  fail=1
fi

code="$(curl -k -s -m 5 -o /dev/null -w "%{http_code}" "https://127.0.0.1:${PORT}/health" 2>/dev/null || echo "000")"
if [[ "$code" != "200" ]]; then
  echo "check-httpd-tls-dhe: FAIL https GET /health expected 200 got $code" >&2
  fail=1
fi

kill "$FE_PID" 2>/dev/null || true
wait "$FE_PID" 2>/dev/null || true

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "check-httpd-tls-dhe: ok (TLS1.2 DHE + https GET)"
