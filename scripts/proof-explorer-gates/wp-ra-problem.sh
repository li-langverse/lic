#!/usr/bin/env bash
# WP-RA: research problem bound in loop state.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
python3 - <<'PY'
import json
from pathlib import Path
state = json.loads(Path("data/proof-explorer-loop/state.json").read_text(encoding="utf-8"))
pid = state.get("research_problem_id") or state.get("current_problem_id")
if not pid:
    raise SystemExit("wp-ra-problem: set research_problem_id in state.json")
print(f"wp-ra-problem: OK (problem_id={pid})")
PY
