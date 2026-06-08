#!/usr/bin/env bash
# WP-PR-06: all catalog open entries must be 0.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

counts="$(bash scripts/proof-explorer-gates/_lib_open_count.sh)"
python3 - "$counts" <<'PY'
import json, sys
counts = json.loads(sys.argv[1])
n = counts.get("open", -1)
if n != 0:
    print(f"wp-pr-06-all-open-closed: INCOMPLETE open={n} proved={counts.get('proved')}", file=sys.stderr)
    sys.exit(1)
print(f"wp-pr-06-all-open-closed: OK proved={counts.get('proved')} total={counts.get('total')}")
PY
