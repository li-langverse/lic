#!/usr/bin/env bash
# wave-d-24: additive.toml row ↔ composable + verticals.toml honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BENCH="$ROOT/benchmarks/competitive/additive.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
COMPOSABLE="$ROOT/li-tests/composable/import_sim_additive_slicer_workflow.li"
MANIFEST="$ROOT/li-tests/manifest.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"
RFC="$ROOT/docs/game-dev/specs/li-sim-additive-rfc.md"

li_phase "am_slicer bench (sim.additive slicer workflow)"
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
    errors.append("additive.toml: [[benchmark]] must be non-empty")

am: dict | None = None
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"benchmark[{i}]: not a table")
        continue
    if row.get("id") == "am_slicer":
        am = row

if am is None:
    errors.append("additive.toml: missing [[benchmark]] id=am_slicer")
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
        if key not in am:
            errors.append(f"am_slicer: missing field {key}")
    if am.get("vertical_id") != "am_slicer":
        errors.append("am_slicer: vertical_id must be am_slicer")
    if am.get("workload_class") != "stub":
        errors.append("am_slicer: workload_class must be stub")
    if am.get("oracle") != "composable_only":
        errors.append("am_slicer: oracle must be composable_only")
    if am.get("li_package") != "sim.additive":
        errors.append("am_slicer: li_package must be sim.additive")
    if am.get("profile") != "sim_additive":
        errors.append("am_slicer: profile must be sim_additive")
    comp = am.get("composable", "")
    if comp != "import_sim_additive_slicer_workflow":
        errors.append(f"am_slicer: composable must be import_sim_additive_slicer_workflow, got {comp!r}")

verticals = tomllib.loads(verticals_path.read_text())
vrows = verticals.get("vertical") or []
v_am = next((r for r in vrows if isinstance(r, dict) and r.get("id") == "am_slicer"), None)
if v_am is None:
    errors.append("verticals.toml: missing am_slicer row")
else:
    if v_am.get("workload_class") != "stub":
        errors.append("verticals.toml am_slicer workload_class must be stub")
    if v_am.get("oracle") != "composable_only":
        errors.append("verticals.toml am_slicer oracle must be composable_only")
    notes = str(v_am.get("notes", ""))
    for token in ("additive.toml", "import_sim_additive_slicer_workflow", "PrusaSlicer", "stub"):
        if token not in notes:
            errors.append(f"verticals.toml am_slicer notes must mention {token!r}")

manifest = manifest_path.read_text()
if "import_sim_additive_slicer_workflow.li" not in manifest:
    errors.append("li-tests/manifest.toml must list import_sim_additive_slicer_workflow.li")

catalog = catalog_path.read_text()
if "import_sim_additive_slicer_workflow" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite import_sim_additive_slicer_workflow")
if "additive.toml" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite additive.toml")

rfc = rfc_path.read_text()
for token in ("PH-AM", "am_slicer", "sim_additive", "import_sim_additive_slicer_workflow"):
    if token not in rfc:
        errors.append(f"li-sim-additive-rfc.md must mention {token!r}")

comp_src = composable_path.read_text()
for token in (
    "sim_additive_workload_class_stub",
    "slicer_workflow_init",
    "slicer_workflow_advance",
    "slicer_workflow_smoke_export_clicks",
    "slicer_smoke_entry",
):
    if token not in comp_src:
        errors.append(f"composable must call {token!r}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("additive-bench: ok (am_slicer)")
PY

li_ok "am_slicer bench"
