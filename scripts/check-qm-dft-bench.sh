#!/usr/bin/env bash
# wave-d-21: qm_dft.toml row ↔ composable + verticals.toml honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BENCH="$ROOT/benchmarks/competitive/qm_dft.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
COMPOSABLE="$ROOT/li-tests/composable/import_chem_dft_smoke.li"
MANIFEST="$ROOT/li-tests/manifest.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"

li_phase "qm_dft bench (chem DFT smoke)"
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
    errors.append("qm_dft.toml: [[benchmark]] must be non-empty")

qm: dict | None = None
for i, row in enumerate(rows or []):
    if not isinstance(row, dict):
        errors.append(f"benchmark[{i}]: not a table")
        continue
    if row.get("id") == "qm_dft":
        qm = row

if qm is None:
    errors.append("qm_dft.toml: missing [[benchmark]] id=qm_dft")
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
        if key not in qm:
            errors.append(f"qm_dft: missing field {key}")
    if qm.get("vertical_id") != "qm_dft":
        errors.append("qm_dft: vertical_id must be qm_dft")
    if qm.get("workload_class") != "stub":
        errors.append("qm_dft: workload_class must be stub")
    if qm.get("oracle") != "composable_only":
        errors.append("qm_dft: oracle must be composable_only (external_binary TBD)")
    if qm.get("li_package") != "chem":
        errors.append("qm_dft: li_package must be chem")
    comp = qm.get("composable", "")
    if comp != "import_chem_dft_smoke":
        errors.append(f"qm_dft: composable must be import_chem_dft_smoke, got {comp!r}")

verticals = tomllib.loads(verticals_path.read_text())
vrows = verticals.get("vertical") or []
v_qm = next((r for r in vrows if isinstance(r, dict) and r.get("id") == "qm_dft"), None)
if v_qm is None:
    errors.append("verticals.toml: missing qm_dft row")
else:
    if v_qm.get("workload_class") != "stub":
        errors.append("verticals.toml qm_dft workload_class must be stub")
    if v_qm.get("oracle") != "external_binary":
        errors.append("verticals.toml qm_dft oracle must be external_binary (target)")
    notes = str(v_qm.get("notes", ""))
    for token in ("qm_dft.toml", "import_chem_dft_smoke", "Gaussian", "stub"):
        if token not in notes:
            errors.append(f"verticals.toml qm_dft notes must mention {token!r}")

manifest = manifest_path.read_text()
if "import_chem_dft_smoke.li" not in manifest:
    errors.append("li-tests/manifest.toml must list import_chem_dft_smoke.li")

catalog = catalog_path.read_text()
if "import_chem_dft_smoke" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite import_chem_dft_smoke")
if "qm_dft.toml" not in catalog:
    errors.append("vertical-algorithm-catalog.md must cite qm_dft.toml")

comp_src = composable_path.read_text()
for token in (
    "chem_workload_class_stub",
    "dft_geometry_h2",
    "dft_single_point_rks_stub",
    "dft_smoke_h2_energy_hartree",
):
    if token not in comp_src:
        errors.append(f"composable must call {token!r}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("qm-dft-bench: ok (qm_dft)")
PY

li_ok "qm_dft bench"
