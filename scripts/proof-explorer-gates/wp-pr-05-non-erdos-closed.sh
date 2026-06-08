#!/usr/bin/env bash
# WP-PR-05: non-Erdős open entries must be 0 (milestone toward full closure).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

counts="$(bash scripts/proof-explorer-gates/_lib_open_count.sh)"
python3 - "$counts" <<'PY'
import json, sys
counts = json.loads(sys.argv[1])
n = counts.get("open_non_erdos", -1)
if n != 0:
    print(f"wp-pr-05-non-erdos-closed: INCOMPLETE open_non_erdos={n}", file=sys.stderr)
    sys.exit(1)
print("wp-pr-05-non-erdos-closed: OK")
PY
