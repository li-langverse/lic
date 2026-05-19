#!/usr/bin/env bash
# Pre-merge World Studio gate (wraps ci-world-studio + prints rollup).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

li_banner "World Studio pre-merge gate"
"$ROOT/scripts/ci-world-studio.sh"

if [[ -f "$ROOT/deploy/studio-demo/status.json" ]]; then
  li_phase "status.json"
  python3 - <<'PY' "$ROOT/deploy/studio-demo/status.json"
import json, sys
d = json.load(open(sys.argv[1]))
print(f"  composable={d.get('composable_gates')} game_dev={d.get('game_dev_gates')} "
      f"vertical={d.get('vertical_demo_builds')} spinup={d.get('spinup_templates')}")
PY
fi

li_gate_ok "world studio pre-merge"
