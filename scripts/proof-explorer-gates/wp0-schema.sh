#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
test -f proof-db/attribution.toml
test -f data/goal-directed-sprints/proof-explorer-program.md
python scripts/proof-db/proof-db.py verify-slice
echo "wp0-schema: OK (bootstrap — schema v3 fields pending)"
