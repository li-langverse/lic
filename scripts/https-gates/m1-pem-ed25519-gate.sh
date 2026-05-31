#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo "== m1-pem-ed25519-gate =="
[[ -x "$ROOT/build/compiler/lic/lic" ]] || [[ -x "$ROOT/build/lic" ]] || ./scripts/build.sh
LIC="$("$ROOT/scripts/resolve-lic.sh")"
PKG="$ROOT/packages/li-crypto"
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)
[[ -f "$PKG/li-tests/smoke/pem_ed25519.li" ]] || { echo "missing pem_ed25519.li"; exit 1; }
"$LIC" build "${BUILD_FLAGS[@]}" "$PKG/li-tests/smoke/pem_ed25519.li" -o "$ROOT/build/li-crypto-pem-smoke"
"$ROOT/build/li-crypto-pem-smoke"
echo "m1-pem-ed25519-gate: OK"
