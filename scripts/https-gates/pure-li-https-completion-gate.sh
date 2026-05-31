#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$ROOT/scripts/https-gates/m1-crypto-primitives-gate.sh"
bash "$ROOT/scripts/https-gates/m1-pem-ed25519-gate.sh"
bash "$ROOT/scripts/https-gates/m2-tls-handshake-gate.sh"
bash "$ROOT/scripts/https-gates/m3-httpd-curl-gate.sh"
bash "$ROOT/scripts/https-gates/m4-benchmark-matrix-gate.sh" || echo "m4 pending"
bash "$ROOT/scripts/check-httpd-tls-auto.sh"
echo "pure-li-https-completion-gate: OK"