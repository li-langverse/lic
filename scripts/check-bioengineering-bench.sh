#!/usr/bin/env bash
# wave-d-22: bioengineering.toml row ↔ composable + verticals.toml honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BENCH="$ROOT/benchmarks/competitive/bioengineering.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
COMPOSABLE="$ROOT/li-tests/composable/import_bioeng_litl_workflow.li"
MANIFEST="$ROOT/li-tests/manifest.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"

li_phase "bio_litl bench (bioeng LITL workflow)"
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
    errors.append("bioengineering.toml: [[benchmark]] must be non-empty")

bio: dict | None = None
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"benchmark[{i}]: not a table")
        continue
    if row.get("id") == "bio_litl":
        bio = row

if bio is None:
    errors.append("bioengineering.toml: missing [[benchmark]] id=bio_litl")
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
        if key not in bio:
            errors.append(f"bio_litl: missing field {key}")
    if bio.get("vertical_id") != "bio_litl":
        errors.append("bio_litl: vertical_id must be bio_litl")
    if bio.get("workload_class") != "stub":
        errors.append("bio_litl: workload_class must be stub")
    if bio.get("oracle") != "composable_only":
        errors.append("bio_litl: oracle must be composable_only")
    if bio.get("li_package") != "bioeng":
        errors.append("bio_litl: li_package must be bioeng")
    comp = bio.get("composable", "")
    if comp != "import_bioeng_litl_workflow":
        errors.append(f"bio_litl: composable must be import_bioeng_litl_workflow, got {comp!r}")

verticals = tomllib.loads(verticals_path.read_text())
vrows = verticals.get("vertical") or []
v_bio = next((r for r in vrows if isinstance(r, dict) and r.get("id") == "bio_litl"), None)
if v_bio is None:
    errors.append("verticals.toml: missing bio_litl row")
else:
    if v_bio.get("workload_class") != "stub":
        errors.append("verticals.toml bio_litl workload_class must be stub")
    if v_bio.get("oracle") != "composable_only":
        errors.append("verticals.toml bio_litl oracle must be composable_only")
    notes = str(v_bio.get("notes", ""))
    for token in ("bioengineering.toml", "import_bioeng_litl_workflow", "Benchling", "stub"):
        if token not in notes:
            errors.append(f"verticals.toml bio_litl notes must mention {token!r}")

manifest = manifest_path.read_text()
if "import_bioeng_litl_workflow.li" not in manifest:
    errors.append("li-tests/manifest.toml must list import_bioeng_litl_workflow.li")

catalog = catalog_path.read_text()
if "import_bioeng_litl_workflow" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite import_bioeng_litl_workflow")
if "bioengineering.toml" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite bioengineering.toml")

comp_src = composable_path.read_text()
for token in (
    "bioeng_workload_class_stub",
    "litl_workflow_init",
    "litl_workflow_advance",
    "litl_workflow_smoke_cycle_count",
    "litl_smoke_entry",
):
    if token not in comp_src:
        errors.append(f"composable must call {token!r}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("bioengineering-bench: ok (bio_litl)")
PY

li_ok "bio_litl bench"
