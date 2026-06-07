#!/usr/bin/env bash
# WP-CQ-01: regenerate discrepancies + library divergent count within budget.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 scripts/proof-db/compare_reference.py --write
test -f proof-database/discrepancies.json
test -f proof-database/DISCREPANCIES.md

MAX_DIVERGENT="${MAX_DIVERGENT:-5}"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
if [[ -z "$PL" || ! -f "$PL/scripts/build-library.py" ]]; then
  echo "wp-cq-01: proof-library missing; skip divergent budget" >&2
  exit 1
fi

LIC_ROOT="$ROOT" python3 "$PL/scripts/build-library.py" >/dev/null
python3 - "$PL/data/library.json" "$MAX_DIVERGENT" <<'PY'
import json
import sys
from pathlib import Path

lib = Path(sys.argv[1])
budget = int(sys.argv[2])
data = json.loads(lib.read_text(encoding="utf-8"))
div = sum(1 for e in data.get("entries") or [] if e.get("diverges"))
disc = data.get("summary", {}).get("discrepancy_register_count", 0)
print(f"wp-cq-01: divergent={div} budget={budget} discrepancies={disc}")
if div > budget:
    bad = [e["id"] for e in data["entries"] if e.get("diverges")][:12]
    print(f"wp-cq-01: still divergent: {', '.join(bad)}", file=sys.stderr)
    sys.exit(1)
PY

echo "wp-cq-01-divergence-reconcile: OK"
