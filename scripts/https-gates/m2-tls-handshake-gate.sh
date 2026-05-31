#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$ROOT/build/lic"; [[ -x "$LIC" ]] || LIC="$ROOT/build/lic.exe"
PKG="$ROOT/packages/li-tls"
"$LIC" build "$PKG/src/lib.li" -o "$ROOT/build/li-tls-test"
[[ -f "$PKG/li-tests/smoke/handshake.li" ]] || { echo "missing handshake.li"; exit 1; }
"$LIC" build "$PKG/li-tests/smoke/handshake.li" -o "$ROOT/build/li-tls-handshake-smoke"
"$ROOT/build/li-tls-handshake-smoke"
echo "m2-tls-handshake-gate: OK"