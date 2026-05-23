#!/usr/bin/env bash
# wave-d-23: robotics.toml row ↔ composable + verticals.toml honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BENCH="$ROOT/benchmarks/competitive/robotics.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
COMPOSABLE="$ROOT/li-tests/composable/import_sim_robotics_workspace.li"
MANIFEST="$ROOT/li-tests/manifest.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"
RFC="$ROOT/docs/game-dev/specs/li-sim-robotics-rfc.md"

li_phase "robo_workspace bench (sim.robotics workspace)"
[[ -f "$BENCH" ]] || { li_fail "missing $BENCH"; exit 1; }
[[ -f "$VERTICALS" ]] || { li_fail "missing $VERTICALS"; exit 1; }
[[ -f "$COMPOSABLE" ]] || { li_fail "missing $COMPOSABLE"; exit 1; }
[[ -f "$MANIFEST" ]] || { li_fail "missing $MANIFEST"; exit 1; }
[[ -f "$CATALOG" ]] || { li_fail "missing $CATALOG"; exit 1; }
[[ -f "$RFC" ]] || { li_fail "missing $RFC"; exit 1; }

export BENCH VERTICALS COMPOSABLE MANIFEST CATALOG RFC
python3 - <<'PY'
from __future__ import annotations

import os
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

bench_path = Path(os.environ["BENCH"])
verticals_path = Path(os.environ["VERTICALS"])
composable_path = Path(os.environ["COMPOSABLE"])
manifest_path = Path(os.environ["MANIFEST"])
catalog_path = Path(os.environ["CATALOG"])
rfc_path = Path(os.environ["RFC"])

errors: list[str] = []

bench = tomllib.loads(bench_path.read_text())
rows = bench.get("benchmark")
if not isinstance(rows, list) or not rows:
    errors.append("robotics.toml: [[benchmark]] must be non-empty")

robo: dict | None = None
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"benchmark[{i}]: not a table")
        continue
    if row.get("id") == "robo_workspace":
        robo = row

if robo is None:
    errors.append("robotics.toml: missing [[benchmark]] id=robo_workspace")
else:
    required = (
        "vertical_id",
        "workload_class",
        "oracle",
        "li_package",
        "composable",
        "profile",
        "status",
    )
    for key in required:
        if key not in robo:
            errors.append(f"robo_workspace: missing field {key}")
    if robo.get("vertical_id") != "robo_workspace":
        errors.append("robo_workspace: vertical_id must be robo_workspace")
    if robo.get("workload_class") != "stub":
        errors.append("robo_workspace: workload_class must be stub")
    if robo.get("oracle") != "composable_only":
        errors.append("robo_workspace: oracle must be composable_only")
    if robo.get("li_package") != "sim.robotics":
        errors.append("robo_workspace: li_package must be sim.robotics")
    if robo.get("profile") != "sim_robotics":
        errors.append("robo_workspace: profile must be sim_robotics")
    comp = robo.get("composable", "")
    if comp != "import_sim_robotics_workspace":
        errors.append(f"robo_workspace: composable must be import_sim_robotics_workspace, got {comp!r}")

verticals = tomllib.loads(verticals_path.read_text())
vrows = verticals.get("vertical") or []
v_robo = next((r for r in vrows if isinstance(r, dict) and r.get("id") == "robo_workspace"), None)
if v_robo is None:
    errors.append("verticals.toml: missing robo_workspace row")
else:
    if v_robo.get("workload_class") != "stub":
        errors.append("verticals.toml robo_workspace workload_class must be stub")
    if v_robo.get("oracle") != "composable_only":
        errors.append("verticals.toml robo_workspace oracle must be composable_only")
    notes = str(v_robo.get("notes", ""))
    for token in ("robotics.toml", "import_sim_robotics_workspace", "Gazebo", "stub"):
        if token not in notes:
            errors.append(f"verticals.toml robo_workspace notes must mention {token!r}")

manifest = manifest_path.read_text()
if "import_sim_robotics_workspace.li" not in manifest:
    errors.append("li-tests/manifest.toml must list import_sim_robotics_workspace.li")

catalog = catalog_path.read_text()
if "import_sim_robotics_workspace" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite import_sim_robotics_workspace")
if "robotics.toml" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite robotics.toml")

rfc = rfc_path.read_text()
for token in ("PH-ROBO", "robo_workspace", "sim_robotics", "import_sim_robotics_workspace"):
    if token not in rfc:
        errors.append(f"li-sim-robotics-rfc.md must mention {token!r}")

comp_src = composable_path.read_text()
for token in (
    "sim_robotics_workload_class_stub",
    "robo_workspace_init",
    "robo_workspace_advance",
    "robo_workspace_smoke_tick_count",
    "robo_smoke_entry",
):
    if token not in comp_src:
        errors.append(f"composable must call {token!r}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("robotics-bench: ok (robo_workspace)")
PY

li_ok "robo_workspace bench"
