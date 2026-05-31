#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[[ "$(uname -s)" == "Linux" ]] || { echo "skip non-Linux"; exit 0; }
[[ -x "$ROOT/build/li-httpd" ]] || ./scripts/build-li-httpd.sh
EXAMPLE="$ROOT/packages/li-net-httpd/examples/tls_h2.toml"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
python3 "$ROOT/scripts/setup-tls-httpd.py" "$EXAMPLE" -o "$WORK/certs" || true
python3 "$ROOT/scripts/flatten-httpd-config.py" "$EXAMPLE" -o "$WORK/runtime.conf"
mkdir -p "$ROOT/packages/li-net-httpd/public"; echo ok > "$ROOT/packages/li-net-httpd/public/health"
"$ROOT/build/li-httpd" "$WORK/runtime.conf" & PID=$!; sleep 1
curl -kfsS --max-time 5 "https://127.0.0.1:18443/health" | grep -q ok
kill $PID 2>/dev/null || true
echo "m3-httpd-curl-gate: OK"