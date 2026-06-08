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
signoff = Path("data/proof-explorer-loop/wp-cq-catalog-quality.signoff")
log = Path("data/proof-explorer-loop/iteration-log.md")
log_text = log.read_text(encoding="utf-8", errors="replace").lower() if log.is_file() else ""
if not log.is_file() or "phase12" not in log_text:
    print("wp-cq-07: iteration-log missing phase12 mention", file=sys.stderr)
    sys.exit(1)
if not signoff.is_file():
    print("wp-cq-07: missing wp-cq-catalog-quality.signoff", file=sys.stderr)
    sys.exit(1)
if phase == 12:
    if "phase12" not in sprint:
        print(f"wp-cq-07: sprint={sprint!r} unexpected for phase 12", file=sys.stderr)
        sys.exit(1)
elif phase is not None and phase > 12:
    pass  # phase12 completed; loop advanced (e.g. phase13 on main)
else:
    print(f"wp-cq-07: phase={phase} (want >= 12)", file=sys.stderr)
    sys.exit(1)
print("wp-cq-07-loop-state: OK")
PY
