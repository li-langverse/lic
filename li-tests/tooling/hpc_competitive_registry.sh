#!/usr/bin/env bash
# Gate: competitive registry schema + MD external oracle stub.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/check-hpc-competitive.sh"
chmod +x "$ROOT/scripts/check-md-oracle.sh"
chmod +x "$ROOT/li-tests/tooling/md_external_oracle_stub.sh"
export LI_HPC_COMPETITIVE_STRICT="${LI_HPC_COMPETITIVE_STRICT:-0}"
"$ROOT/scripts/check-hpc-competitive.sh"
"$ROOT/li-tests/tooling/md_external_oracle_stub.sh"
echo "hpc_competitive_registry: ok"
