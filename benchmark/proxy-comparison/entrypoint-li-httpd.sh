#!/usr/bin/env bash
set -euo pipefail
CONF=/run/httpd.runtime.conf
BACKEND_IP=$(getent ahostsv4 backend | awk '{print $1; exit}')
[ -n "$BACKEND_IP" ] || { echo "entrypoint: cannot resolve backend" >&2; exit 1; }
socat "TCP-LISTEN:8080,bind=127.0.0.1,fork,reuseaddr" "TCP:${BACKEND_IP}:8080" &
SOCAT_PID=$!
trap 'kill "$SOCAT_PID" 2>/dev/null || true' EXIT
CERT_DIR=/run/certs
mkdir -p "$CERT_DIR"
python3 /opt/lic-scripts/setup-tls-httpd.py /proxy/httpd.toml --cert-dir "$CERT_DIR"
python3 /opt/lic-scripts/validate-httpd-config.py /proxy/httpd.toml --allow-peer-host backend
python3 /opt/lic-scripts/flatten-httpd-config.py /proxy/httpd.toml -o "$CONF"
sed -i "s|^tls_cert_dir=.*|tls_cert_dir=$CERT_DIR|" "$CONF"
grep -q '^m2_tls_terminate=1' "$CONF"
WORKERS="${LI_HTTPD_WORKERS:-auto}"
exec env LI_HTTPD_WORKERS="$WORKERS" /usr/local/bin/li-httpd "$CONF"
