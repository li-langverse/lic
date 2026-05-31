#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo "== m1-crypto-primitives-gate =="
[[ -x "$ROOT/build/lic" ]] || [[ -x "$ROOT/build/lic.exe" ]] || ./scripts/build.sh
LIC="$ROOT/build/lic"; [[ -x "$LIC" ]] || LIC="$ROOT/build/lic.exe"
PKG="$ROOT/packages/li-crypto"
"$LIC" build "$PKG/src/lib.li" -o "$ROOT/build/li-crypto-test"
if [[ -f "$PKG/li-tests/smoke/primitives.li" ]]; then
  "$LIC" build "$PKG/li-tests/smoke/primitives.li" -o "$ROOT/build/li-crypto-prim-smoke"
  "$ROOT/build/li-crypto-prim-smoke"
fi
echo "m1-crypto-primitives-gate: OK"