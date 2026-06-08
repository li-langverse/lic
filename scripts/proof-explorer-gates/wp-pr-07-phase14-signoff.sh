#!/usr/bin/env bash
# WP-PR-07: phase14 loop state + signoff + iteration log.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

test -f data/proof-explorer-loop/wp-pr-phase14.signoff || {
  echo "wp-pr-07: missing wp-pr-phase14.signoff (create when gate passes)" >&2
  exit 1
}

python3 - <<'PY'
import json
import sys
from pathlib import Path

state_path = Path("data/proof-explorer-loop/state.json")
log_path = Path("data/proof-explorer-loop/iteration-log.md")

if state_path.is_file():
    state = json.loads(state_path.read_text(encoding="utf-8"))
    phase = state.get("phase")
    sprint = state.get("sprint", "")
    if phase not in (14, "14") and "phase14" not in sprint:
        print(f"wp-pr-07: state phase={phase} sprint={sprint!r}", file=sys.stderr)
        sys.exit(1)

if log_path.is_file():
    text = log_path.read_text(encoding="utf-8", errors="replace").lower()
    if "phase14" not in text and "phase 14" not in text:
        print("wp-pr-07: iteration-log missing phase14 mention", file=sys.stderr)
        sys.exit(1)
else:
    print("wp-pr-07: missing iteration-log.md", file=sys.stderr)
    sys.exit(1)

print("wp-pr-07-phase14-signoff: OK")
PY
