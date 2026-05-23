#!/usr/bin/env bash
# wave-d-26: mmorpg.toml row ↔ composable + verticals.toml honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BENCH="$ROOT/benchmarks/competitive/mmorpg.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
COMPOSABLE="$ROOT/li-tests/composable/import_mmo_shard.li"
MANIFEST="$ROOT/li-tests/manifest.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"

li_phase "mmo_shard bench (mmo shard composable)"
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
    errors.append("mmorpg.toml: [[benchmark]] must be non-empty")

mmo: dict | None = None
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"benchmark[{i}]: not a table")
        continue
    if row.get("id") == "mmo_shard":
        mmo = row

if mmo is None:
    errors.append("mmorpg.toml: missing [[benchmark]] id=mmo_shard")
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
        if key not in mmo:
            errors.append(f"mmo_shard: missing field {key}")
    if mmo.get("vertical_id") != "mmo_shard":
        errors.append("mmo_shard: vertical_id must be mmo_shard")
    if mmo.get("workload_class") != "stub":
        errors.append("mmo_shard: workload_class must be stub")
    if mmo.get("oracle") != "composable_only":
        errors.append("mmo_shard: oracle must be composable_only")
    if mmo.get("li_package") != "mmo":
        errors.append("mmo_shard: li_package must be mmo")
    if mmo.get("profile") != "mmo":
        errors.append("mmo_shard: profile must be mmo")
    comp = mmo.get("composable", "")
    if comp != "import_mmo_shard":
        errors.append(f"mmo_shard: composable must be import_mmo_shard, got {comp!r}")

verticals = tomllib.loads(verticals_path.read_text())
vrows = verticals.get("vertical") or []
v_mmo = next((r for r in vrows if isinstance(r, dict) and r.get("id") == "mmo_shard"), None)
if v_mmo is None:
    errors.append("verticals.toml: missing mmo_shard row")
else:
    if v_mmo.get("workload_class") != "stub":
        errors.append("verticals.toml mmo_shard workload_class must be stub")
    if v_mmo.get("oracle") != "composable_only":
        errors.append("verticals.toml mmo_shard oracle must be composable_only")
    notes = str(v_mmo.get("notes", ""))
    for token in ("mmorpg.toml", "import_mmo_shard", "Photon", "stub"):
        if token not in notes:
            errors.append(f"verticals.toml mmo_shard notes must mention {token!r}")

manifest = manifest_path.read_text()
if "import_mmo_shard.li" not in manifest:
    errors.append("li-tests/manifest.toml must list import_mmo_shard.li")

catalog = catalog_path.read_text()
if "import_mmo_shard" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite import_mmo_shard")
if "mmorpg.toml" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite mmorpg.toml")

comp_src = composable_path.read_text()
for token in (
    "mmo_workload_class_stub",
    "mmo_shard_init",
    "mmo_shard_advance",
    "mmo_shard_smoke_tick_count",
    "mmo_smoke_entry",
):
    if token not in comp_src:
        errors.append(f"composable must call {token!r}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("mmorpg-bench: ok (mmo_shard)")
PY

li_ok "mmo_shard bench"
