#!/usr/bin/env bash
# WP-T10-06: discrepancy register triage â€” regenerate + budget.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

bash scripts/proof-explorer-gates/wp-discrepancy-reconcile.sh

MAX_DISC="${MAX_DISCREPANCY:-30}"
python3 - <<PY
import json
from pathlib import Path
rows = json.loads(Path("proof-database/discrepancies.json").read_text(encoding="utf-8"))
n = len(rows.get("discrepancies") or [])
budget = int("$MAX_DISC")
print(f"wp-t10-06: discrepancies={n} budget={budget}")
if n > budget:
    raise SystemExit(1)
print("wp-t10-06-discrepancy-triage: OK")
PY
