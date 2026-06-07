#!/usr/bin/env bash
# WP-T10-10: phase13 loop state + signoff + iteration log.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

test -f data/proof-explorer-loop/wp-t10-ten-of-ten.signoff

python3 - <<'PY'
import json
import sys
from pathlib import Path

path = Path("data/proof-explorer-loop/state.json")
if not path.is_file():
    print("wp-t10-10: missing state.json", file=sys.stderr)
    sys.exit(1)
state = json.loads(path.read_text(encoding="utf-8"))
phase = state.get("phase")
sprint = state.get("sprint", "")
if phase != 13:
    print(f"wp-t10-10: phase={phase} (want 13)", file=sys.stderr)
    sys.exit(1)
if "phase13" not in sprint:
    print(f"wp-t10-10: sprint={sprint!r} unexpected", file=sys.stderr)
    sys.exit(1)
log = Path("data/proof-explorer-loop/iteration-log.md")
if not log.is_file() or "phase13" not in log.read_text(encoding="utf-8", errors="replace").lower():
    print("wp-t10-10: iteration-log missing phase13 mention", file=sys.stderr)
    sys.exit(1)
print("wp-t10-10-phase13-signoff: OK")
PY
