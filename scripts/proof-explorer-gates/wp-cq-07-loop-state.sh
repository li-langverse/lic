#!/usr/bin/env bash
# WP-CQ-07: proof-explorer loop state targets phase 12.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
import sys
from pathlib import Path

path = Path("data/proof-explorer-loop/state.json")
if not path.is_file():
    print("wp-cq-07: missing state.json", file=sys.stderr)
    sys.exit(1)
state = json.loads(path.read_text(encoding="utf-8"))
phase = state.get("phase")
sprint = state.get("sprint", "")
if phase != 12:
    print(f"wp-cq-07: phase={phase} (want 12)", file=sys.stderr)
    sys.exit(1)
if "phase12" not in sprint:
    print(f"wp-cq-07: sprint={sprint!r} unexpected", file=sys.stderr)
    sys.exit(1)
log = Path("data/proof-explorer-loop/iteration-log.md")
if not log.is_file() or "phase12" not in log.read_text(encoding="utf-8", errors="replace").lower():
    print("wp-cq-07: iteration-log missing phase12 mention", file=sys.stderr)
    sys.exit(1)
print("wp-cq-07-loop-state: OK")
PY
