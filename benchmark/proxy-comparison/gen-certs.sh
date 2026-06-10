#!/usr/bin/env bash
# Self-signed TLS for gitlab.lilangverse.xyz — shared across all proxy services.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
CERT_DIR="${1:-$DIR/certs}"
mkdir -p "$CERT_DIR"
if [ -f "$CERT_DIR/cert.pem" ] && [ -f "$CERT_DIR/key.pem" ]; then
  echo "certs: already present in $CERT_DIR"
  exit 0
fi
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout "$CERT_DIR/key.pem" \
  -out "$CERT_DIR/cert.pem" \
  -days 30 \
  -subj "/CN=gitlab.lilangverse.xyz" \
  -addext "subjectAltName=DNS:gitlab.lilangverse.xyz"
cat "$CERT_DIR/cert.pem" "$CERT_DIR/key.pem" > "$CERT_DIR/combined.pem"
echo "certs: wrote $CERT_DIR/{cert,key,combined}.pem"
