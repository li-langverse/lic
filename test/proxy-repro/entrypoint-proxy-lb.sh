#!/usr/bin/env bash
set -euo pipefail
CONF=/run/httpd.runtime.conf
BACKEND_A_IP=$(getent ahostsv4 backend-a | awk '{print $1; exit}')
BACKEND_B_IP=$(getent ahostsv4 backend-b | awk '{print $1; exit}')
[ -n "$BACKEND_A_IP" ] && [ -n "$BACKEND_B_IP" ] || { echo "entrypoint-lb: cannot resolve backends" >&2; exit 1; }
socat "TCP-LISTEN:18080,bind=127.0.0.1,fork,reuseaddr" "TCP:${BACKEND_A_IP}:8080" &
socat "TCP-LISTEN:18081,bind=127.0.0.1,fork,reuseaddr" "TCP:${BACKEND_B_IP}:8080" &
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT
python3 /opt/lic-scripts/validate-httpd-config.py /proxy/httpd-lb.toml --allow-peer-host backend-a --allow-peer-host backend-b
python3 /opt/lic-scripts/setup-tls-httpd.py /proxy/httpd-lb.toml --cert-dir /certs
python3 /opt/lic-scripts/flatten-httpd-config.py /proxy/httpd-lb.toml -o "$CONF"
sed -i "s|^tls_cert_dir=.*|tls_cert_dir=/certs|" "$CONF"
grep -q '^upstream_balance=gitlab|ip_hash' "$CONF"
grep -q '^upstream_peer=gitlab|127.0.0.1|18080' "$CONF"
grep -q '^upstream_peer=gitlab|127.0.0.1|18081' "$CONF"
exec env LI_HTTPD_WORKERS=1 /usr/local/bin/li-httpd "$CONF"
