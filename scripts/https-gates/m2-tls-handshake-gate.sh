#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo "== m2-tls-handshake-gate =="
[[ -x "$ROOT/build/compiler/lic/lic" ]] || [[ -x "$ROOT/build/lic" ]] || ./scripts/build.sh
LIC="$("$ROOT/scripts/resolve-lic.sh")"
PKG="$ROOT/packages/li-tls"
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)
"$LIC" build "${BUILD_FLAGS[@]}" "$PKG/src/lib.li" -o "$ROOT/build/li-tls-test"
[[ -f "$PKG/li-tests/smoke/handshake.li" ]] || { echo "missing handshake.li"; exit 1; }
"$LIC" build "${BUILD_FLAGS[@]}" "$PKG/li-tests/smoke/handshake.li" -o "$ROOT/build/li-tls-handshake-smoke"
"$ROOT/build/li-tls-handshake-smoke"
echo "m2-tls-handshake-gate: OK"