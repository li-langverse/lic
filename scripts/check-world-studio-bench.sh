#!/usr/bin/env bash
# wave-d-19: world-studio.toml gaming_rigid row ↔ composable + verticals.toml honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BENCH="$ROOT/benchmarks/competitive/world-studio.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
COMPOSABLE="$ROOT/li-tests/composable/import_physics_rigid_gaming.li"
MANIFEST="$ROOT/li-tests/manifest.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"

li_phase "world-studio bench (gaming_rigid)"
[[ -f "$BENCH" ]] || { li_fail "missing $BENCH"; exit 1; }
[[ -f "$VERTICALS" ]] || { li_fail "missing $VERTICALS"; exit 1; }
[[ -f "$COMPOSABLE" ]] || { li_fail "missing $COMPOSABLE"; exit 1; }
[[ -f "$MANIFEST" ]] || { li_fail "missing $MANIFEST"; exit 1; }
[[ -f "$CATALOG" ]] || { li_fail "missing $CATALOG"; exit 1; }

export BENCH VERTICALS COMPOSABLE MANIFEST CATALOG
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

errors: list[str] = []

bench = tomllib.loads(bench_path.read_text())
rows = bench.get("benchmark")
if not isinstance(rows, list) or not rows:
    errors.append("world-studio.toml: [[benchmark]] must be non-empty")

gaming: dict | None = None
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"benchmark[{i}]: not a table")
        continue
    if row.get("id") == "gaming_rigid":
        gaming = row

if gaming is None:
    errors.append("world-studio.toml: missing [[benchmark]] id=gaming_rigid")
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
        if key not in gaming:
            errors.append(f"gaming_rigid: missing field {key}")
    if gaming.get("vertical_id") != "gaming_rigid":
        errors.append("gaming_rigid: vertical_id must be gaming_rigid")
    if gaming.get("workload_class") != "v0_gaming":
        errors.append("gaming_rigid: workload_class must be v0_gaming")
    if gaming.get("oracle") != "composable_only":
        errors.append("gaming_rigid: oracle must be composable_only")
    if gaming.get("li_package") != "physics.rigid":
        errors.append("gaming_rigid: li_package must be physics.rigid")
    comp = gaming.get("composable", "")
    if comp != "import_physics_rigid_gaming":
        errors.append(f"gaming_rigid: composable must be import_physics_rigid_gaming, got {comp!r}")

verticals = tomllib.loads(verticals_path.read_text())
vrows = verticals.get("vertical") or []
v_gaming = next((r for r in vrows if isinstance(r, dict) and r.get("id") == "gaming_rigid"), None)
if v_gaming is None:
    errors.append("verticals.toml: missing gaming_rigid row")
else:
    notes = str(v_gaming.get("notes", ""))
    for token in ("world-studio.toml", "import_physics_rigid_gaming"):
        if token not in notes:
            errors.append(f"verticals.toml gaming_rigid notes must mention {token!r}")

manifest = manifest_path.read_text()
if "import_physics_rigid_gaming.li" not in manifest:
    errors.append("li-tests/manifest.toml must list import_physics_rigid_gaming.li")

catalog = catalog_path.read_text()
if "import_physics_rigid_gaming" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite import_physics_rigid_gaming")

comp_src = composable_path.read_text()
for token in (
    "physics_rigid_workload_class_v0_gaming",
    "rigid_integrate_semi_implicit",
    "aabb_overlap",
    "sphere_sphere_overlap",
):
    if token not in comp_src:
        errors.append(f"composable must call {token!r}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("world-studio-bench: ok (gaming_rigid)")
PY

li_ok "world-studio bench"
