#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$ROOT/build/lic"; [[ -x "$LIC" ]] || LIC="$ROOT/build/lic.exe"
PKG="$ROOT/packages/li-crypto"
[[ -f "$PKG/li-tests/smoke/pem_ed25519.li" ]] || { echo "missing pem_ed25519.li"; exit 1; }
"$LIC" build "$PKG/li-tests/smoke/pem_ed25519.li" -o "$ROOT/build/li-crypto-pem-smoke"
"$ROOT/build/li-crypto-pem-smoke"
echo "m1-pem-ed25519-gate: OK"