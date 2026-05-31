#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo "== m1-crypto-primitives-gate =="
[[ -x "$ROOT/build/compiler/lic/lic" ]] || [[ -x "$ROOT/build/lic" ]] || [[ -x "$ROOT/build/lic.exe" ]] || ./scripts/build.sh
LIC="$("$ROOT/scripts/resolve-lic.sh")"
PKG="$ROOT/packages/li-crypto"
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)
"$LIC" build "${BUILD_FLAGS[@]}" "$PKG/src/lib.li" -o "$ROOT/build/li-crypto-test"
if [[ -f "$PKG/li-tests/smoke/primitives.li" ]]; then
  "$LIC" build "${BUILD_FLAGS[@]}" "$PKG/li-tests/smoke/primitives.li" -o "$ROOT/build/li-crypto-prim-smoke"
  "$ROOT/build/li-crypto-prim-smoke"
fi
echo "m1-crypto-primitives-gate: OK"