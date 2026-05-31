#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[[ "$(uname -s)" == "Linux" ]] || { echo "skip non-Linux"; exit 0; }
[[ -x "$ROOT/build/compiler/lic/lic" ]] || [[ -x "$ROOT/build/li-httpd" ]] || ./scripts/build.sh
[[ -x "$ROOT/build/li-httpd" ]] || ./scripts/build-li-httpd.sh
EXAMPLE="$ROOT/packages/li-net-httpd/examples/tls_h2.toml"
PORT=18443
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"; fuser -k '"${PORT}"'/tcp 2>/dev/null || true' EXIT
python3 "$ROOT/scripts/setup-tls-httpd.py" "$EXAMPLE" -o "$WORK/certs"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$EXAMPLE" -o "$WORK/runtime.conf" --cert-dir "$WORK/certs"
PUBLIC="$ROOT/packages/li-net-httpd/examples/public"
mkdir -p "$PUBLIC"
echo ok > "$PUBLIC/healthcheck"
fuser -k "${PORT}/tcp" 2>/dev/null || true
sleep 0.3
LI_HTTPD_WORKERS=1 "$ROOT/build/li-httpd" "$WORK/runtime.conf" >/dev/null 2>&1 &
PID=$!
sleep 1.2
curl -kfsS --http1.1 --max-time 5 "https://127.0.0.1:${PORT}/health" | grep -q ok
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true
echo "m3-httpd-curl-gate: OK"