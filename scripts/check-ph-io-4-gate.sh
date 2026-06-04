#!/usr/bin/env bash
# PH-IO-4 — std.io + std.csv compile harness (no Python ingest shim).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$ROOT"

LIC="${LIC_BIN:-${LIC:-}}"
if [[ -z "$LIC" ]] || ! "$LIC" --version &>/dev/null; then
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi
export LIC

./li-tests/run_all.sh stdlib_seal 2>&1 | tail -5
./li-tests/run_all.sh stdlib_coverage 2>&1 | tail -8

echo "check-ph-io-4-gate: std.io + std.csv harness OK"
