#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
test -f proof-db/attribution.toml
test -f data/goal-directed-sprints/proof-explorer-program.md
test -f docs/verification/proof-database/proof-explorer-style-guide.md
grep -q 'version = 3' docs/verification/proof-database/schema.toml
grep -q '\[footer\]' proof-db/attribution.toml
python3 scripts/proof-db/proof-db.py verify-slice
echo "wp0-schema: OK (schema v3 + attribution + style guide)"
