#!/usr/bin/env bash
# li-tests gate: MD external oracle stub (md-r3-oracle-plan).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/md-oracle-competitive-gates.sh"
"$ROOT/scripts/md-oracle-competitive-gates.sh"
echo "md_external_oracle_stub: ok"
