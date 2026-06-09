#!/usr/bin/env bash
set -euo pipefail
CONF=/run/httpd.runtime.conf
python3 /opt/lic-scripts/validate-httpd-config.py /proxy/httpd.toml
python3 /opt/lic-scripts/setup-tls-httpd.py /proxy/httpd.toml --cert-dir /certs
python3 /opt/lic-scripts/flatten-httpd-config.py /proxy/httpd.toml -o "$CONF"
sed -i "s|^tls_cert_dir=.*|tls_cert_dir=/certs|" "$CONF"
grep -q '^m2_tls_terminate=1' "$CONF"
exec /usr/local/bin/li-httpd "$CONF"
