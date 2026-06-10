#!/usr/bin/env bash
# PH-IO-4 — std.io + std.csv compile harness gate (import resolve + prelude seal).
set -euo pipefail
ROOT="${PH_IO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

LIC="${LIC_BIN:-${LIC:-}}"
if [[ -z "$LIC" ]] || ! "$LIC" --version &>/dev/null; then
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi
export LIC
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)

for mod in std/io/io.li std/csv/csv.li; do
  [[ -f "$mod" ]] || { echo "ph-io-4: missing $mod" >&2; exit 1; }
done

echo "==> PH-IO-4: std.io + std.csv module compile"
"$LIC" build "${BUILD_FLAGS[@]}" std/io/io.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" std/csv/csv.li -o /dev/null

echo "==> PH-IO-4: import harness (stdlib_seal + stdlib_coverage)"
"$ROOT/li-tests/run_all.sh" stdlib_seal
"$ROOT/li-tests/run_all.sh" stdlib_coverage

echo "ph-io-4-std-io gate OK"
