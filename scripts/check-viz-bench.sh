#!/usr/bin/env bash
# wave-d-25: viz.toml row ↔ composable + verticals.toml honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BENCH="$ROOT/benchmarks/competitive/viz.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
COMPOSABLE="$ROOT/li-tests/composable/import_sim_viz_pipeline_source_display.li"
MANIFEST="$ROOT/li-tests/manifest.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"
RFC="$ROOT/docs/game-dev/specs/li-sim-viz-rfc.md"

li_phase "scientific_viz bench (sim.viz pipeline source/display)"
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
    errors.append("viz.toml: [[benchmark]] must be non-empty")

viz: dict | None = None
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"benchmark[{i}]: not a table")
        continue
    if row.get("id") == "scientific_viz":
        viz = row

if viz is None:
    errors.append("viz.toml: missing [[benchmark]] id=scientific_viz")
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
        if key not in viz:
            errors.append(f"scientific_viz: missing field {key}")
    if viz.get("vertical_id") != "scientific_viz":
        errors.append("scientific_viz: vertical_id must be scientific_viz")
    if viz.get("workload_class") != "stub":
        errors.append("scientific_viz: workload_class must be stub")
    if viz.get("oracle") != "composable_only":
        errors.append("scientific_viz: oracle must be composable_only")
    if viz.get("li_package") != "sim.viz":
        errors.append("scientific_viz: li_package must be sim.viz")
    if viz.get("profile") != "sim_scientific":
        errors.append("scientific_viz: profile must be sim_scientific")
    comp = viz.get("composable", "")
    if comp != "import_sim_viz_pipeline_source_display":
        errors.append(f"scientific_viz: composable must be import_sim_viz_pipeline_source_display, got {comp!r}")

verticals = tomllib.loads(verticals_path.read_text())
vrows = verticals.get("vertical") or []
v_viz = next((r for r in vrows if isinstance(r, dict) and r.get("id") == "scientific_viz"), None)
if v_viz is None:
    errors.append("verticals.toml: missing scientific_viz row")
else:
    if v_viz.get("workload_class") != "stub":
        errors.append("verticals.toml scientific_viz workload_class must be stub")
    if v_viz.get("oracle") != "composable_only":
        errors.append("verticals.toml scientific_viz oracle must be composable_only")
    notes = str(v_viz.get("notes", ""))
    for token in ("viz.toml", "import_sim_viz_pipeline_source_display", "ParaView", "stub"):
        if token not in notes:
            errors.append(f"verticals.toml scientific_viz notes must mention {token!r}")

manifest = manifest_path.read_text()
if "import_sim_viz_pipeline_source_display.li" not in manifest:
    errors.append("li-tests/manifest.toml must list import_sim_viz_pipeline_source_display.li")

catalog = catalog_path.read_text()
if "import_sim_viz_pipeline_source_display" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite import_sim_viz_pipeline_source_display")
if "viz.toml" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite viz.toml")

rfc = rfc_path.read_text()
for token in ("PH-SCI", "scientific_viz", "sim_scientific", "import_sim_viz_pipeline_source_display"):
    if token not in rfc:
        errors.append(f"li-sim-viz-rfc.md must mention {token!r}")

comp_src = composable_path.read_text()
for token in (
    "sim_viz_workload_class_stub",
    "viz_pipeline_init",
    "viz_pipeline_add_source",
    "viz_pipeline_set_inspector_section",
    "viz_pipeline_set_display_rep",
    "viz_pipeline_apply",
    "viz_pipeline_smoke_source_count",
    "viz_smoke_entry",
):
    if token not in comp_src:
        errors.append(f"composable must call {token!r}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("viz-bench: ok (scientific_viz)")
PY

li_ok "scientific_viz bench"
