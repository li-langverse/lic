#!/usr/bin/env bash
# Gate: competitive registry schema + optional CSV column hints.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/check-hpc-competitive.sh"
export LI_HPC_COMPETITIVE_STRICT="${LI_HPC_COMPETITIVE_STRICT:-0}"
"$ROOT/scripts/check-hpc-competitive.sh"
chmod +x "$ROOT/li-tests/tooling/md_external_oracle_stub.sh"
"$ROOT/li-tests/tooling/md_external_oracle_stub.sh"
chmod +x "$ROOT/scripts/check-vertical-algorithm-catalog.sh"
"$ROOT/scripts/check-vertical-algorithm-catalog.sh"
chmod +x "$ROOT/scripts/check-cad-fundamentals.sh"
"$ROOT/scripts/check-cad-fundamentals.sh"
chmod +x "$ROOT/scripts/check-engineering-cae-rfc.sh"
"$ROOT/scripts/check-engineering-cae-rfc.sh"
echo "hpc_competitive_registry: ok"
