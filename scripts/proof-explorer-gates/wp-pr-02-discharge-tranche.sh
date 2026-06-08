#!/usr/bin/env bash
# WP-PR-02: discharge tranche — proved count must not regress; progress tracked.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

bash scripts/proof-explorer-gates/wp-pr-01-open-inventory.sh

python3 - <<'PY'
import json
import sys
from pathlib import Path

progress_path = Path("data/proof-explorer-loop/phase14-progress.json")
baseline_path = Path("data/proof-explorer-loop/phase14-baseline.json")
if not progress_path.is_file():
    print("wp-pr-02: run wp-pr-01 first", file=sys.stderr)
    sys.exit(1)

progress = json.loads(progress_path.read_text(encoding="utf-8"))
baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
cur = progress["current"]
base_proved = baseline.get("by_catalog_status", {}).get("proved", 354)
base_open = baseline.get("by_catalog_status", {}).get("open", 1109)

if cur["proved"] < base_proved:
    print(f"wp-pr-02: proved regressed {cur['proved']} < baseline {base_proved}", file=sys.stderr)
    sys.exit(1)

# When open rows remain, iteration should eventually reduce open or increase proved.
# Soft check: warn if zero progress after many iterations is handled by worker stuck threshold.
if cur["open"] >= base_open and cur["proved"] <= base_proved:
    print(
        f"wp-pr-02-discharge-tranche: NO_PROGRESS_YET open={cur['open']} proved={cur['proved']} "
        f"(baseline open={base_open}) — continue discharging",
        file=sys.stderr,
    )
    sys.exit(1)

print(
    f"wp-pr-02-discharge-tranche: OK open={cur['open']} proved={cur['proved']} "
    f"(baseline open={base_open} proved={base_proved})"
)
PY
