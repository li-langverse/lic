#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[[ "$(uname -s)" == "Linux" ]] || { echo "skip non-Linux"; exit 0; }
[[ -x "$ROOT/build/compiler/lic/lic" ]] || [[ -x "$ROOT/build/li-httpd" ]] || ./scripts/build.sh
[[ -x "$ROOT/build/li-httpd" ]] || ./scripts/build-li-httpd.sh
EXAMPLE="$ROOT/packages/li-net-httpd/examples/tls_h2.toml"
PORT="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()')"
WORK="$(mktemp -d)"
CERT_DIR="$WORK/certs"
CONF="$WORK/runtime.conf"
PUBLIC="$WORK/public"
trap 'rm -rf "$WORK"; bash "$ROOT/scripts/httpd-kill-listeners.sh" '"${PORT}"'' EXIT
mkdir -p "$PUBLIC" "$CERT_DIR"
echo ok > "$PUBLIC/health"
python3 "$ROOT/scripts/validate-httpd-config.py" "$EXAMPLE"
python3 "$ROOT/scripts/setup-tls-httpd.py" "$EXAMPLE" --cert-dir "$CERT_DIR"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$EXAMPLE" -o "$CONF"
sed -i "s|^tls_cert_dir=.*|tls_cert_dir=${CERT_DIR}|" "$CONF"
sed -i "s|^document_root=.*|document_root=${PUBLIC}|" "$CONF"
sed -i "s|^listen_port=.*|listen_port=${PORT}|" "$CONF"
grep -q '^tls_enabled=1' "$CONF"
grep -q '^m2_tls_terminate=1' "$CONF"
bash "$ROOT/scripts/httpd-kill-listeners.sh" "${PORT}"
LI_HTTPD_WORKERS=1 LI_HTTPD_TLS_LEGACY_OPENSSL=1 "$ROOT/build/li-httpd" "$CONF" >/dev/null 2>&1 &
PID=$!
for i in 1 2 3 4 5 6 7 8 9 10; do
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "m3-httpd-curl-gate: li-httpd exited before curl (pid=$PID)" >&2
    exit 1
  fi
  if curl -kfsS --http2 --max-time 5 "https://127.0.0.1:${PORT}/health" 2>/dev/null | grep -q ok; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
    echo "m3-httpd-curl-gate: OK"
    exit 0
  fi
  sleep 0.5
done
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true
exit 1
