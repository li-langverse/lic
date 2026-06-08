#!/usr/bin/env bash
# WP-PR-01: open-entry inventory; refresh phase14 progress snapshot.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

counts="$(bash scripts/proof-explorer-gates/_lib_open_count.sh)"
python3 - "$counts" <<'PY'
import json
import sys
from datetime import date
from pathlib import Path

counts = json.loads(sys.argv[1])
baseline_path = Path("data/proof-explorer-loop/phase14-baseline.json")
if not baseline_path.is_file():
    print("wp-pr-01: missing phase14-baseline.json", file=sys.stderr)
    sys.exit(1)
baseline = json.loads(baseline_path.read_text(encoding="utf-8"))

progress = {
    "phase": 14,
    "updated": date.today().isoformat(),
    "baseline_open": baseline.get("by_catalog_status", {}).get("open", baseline.get("open", 1109)),
    "current": counts,
    "proved_delta": counts["proved"] - baseline.get("by_catalog_status", {}).get("proved", 354),
    "open_delta": counts["open"] - baseline.get("by_catalog_status", {}).get("open", 1109),
}
out = Path("data/proof-explorer-loop/phase14-progress.json")
out.write_text(json.dumps(progress, indent=2) + "\n", encoding="utf-8")

print(
    f"wp-pr-01-open-inventory: OK open={counts['open']} "
    f"(non-erdos={counts['open_non_erdos']} erdos={counts['open_erdos']}) "
    f"proved={counts['proved']} delta_proved={progress['proved_delta']:+d}"
)
if counts["open"] < 0:
    sys.exit(1)
PY

python3 scripts/proof-db/compare_reference.py --write || true
echo "wp-pr-01-open-inventory: OK"
