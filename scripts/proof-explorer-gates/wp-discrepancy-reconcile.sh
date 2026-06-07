#!/usr/bin/env bash
# Regenerate proof-database/discrepancies.json from Lean/AutoVC/catalog truth.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 scripts/proof-db/compare_reference.py --write
test -f proof-database/discrepancies.json
test -f proof-database/DISCREPANCIES.md

echo "wp-discrepancy-reconcile: OK ($(python3 -c "import json;print(len(json.load(open('proof-database/discrepancies.json'))['discrepancies']))") discrepancies)"
