#!/usr/bin/env bash
# WP-AX-10: proof-explorer loop state targets phase 10.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
import sys
from pathlib import Path

path = Path("data/proof-explorer-loop/state.json")
if not path.is_file():
    print("wp-ax-10: missing state.json", file=sys.stderr)
    sys.exit(1)
state = json.loads(path.read_text(encoding="utf-8"))
phase = state.get("phase")
branch = state.get("branch", "")
if phase != 10:
    print(f"wp-ax-10: phase={phase} (want 10)", file=sys.stderr)
    sys.exit(1)
if "phase10" not in branch and "axiom" not in branch:
    print(f"wp-ax-10: branch={branch!r} unexpected", file=sys.stderr)
    sys.exit(1)
log = Path("data/proof-explorer-loop/iteration-log.md")
if not log.is_file() or "phase10" not in log.read_text(encoding="utf-8", errors="replace").lower():
    print("wp-ax-10: iteration-log missing phase10 mention", file=sys.stderr)
    sys.exit(1)
print("wp-ax-10-loop-state: OK")
PY
