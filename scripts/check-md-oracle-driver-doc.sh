#!/usr/bin/env bash
# wave-d-20: md_oracle driver stub doc + verticals.toml LAMMPS column plan cross-links.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

README="$ROOT/benchmarks/tier2_physics/md_lennard_jones/external/README.md"
MD_ORACLE="$ROOT/benchmarks/competitive/md_oracle.toml"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"
STUB="$ROOT/benchmarks/tier2_physics/md_lennard_jones/external/run_oracle_stub.sh"

li_phase "MD oracle driver doc (wave-d-20)"
for f in "$README" "$MD_ORACLE" "$VERTICALS" "$CATALOG" "$STUB"; do
  [[ -f "$f" ]] || { li_fail "missing $f"; exit 1; }
done

export README MD_ORACLE VERTICALS CATALOG
python3 - <<'PY'
from __future__ import annotations

import os
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

readme = Path(os.environ["README"]).read_text()
oracle = tomllib.loads(Path(os.environ["MD_ORACLE"]).read_text())
verticals = tomllib.loads(Path(os.environ["VERTICALS"]).read_text())
catalog = Path(os.environ["CATALOG"]).read_text()

errors: list[str] = []

for token in (
    "run_oracle_stub.sh",
    "md_oracle.toml",
    "lammps_lj_micro",
    "gromacs_lj_micro",
    "workload_class=stub",
    "B0",
    "B1",
):
    if token not in readme:
        errors.append(f"README missing token {token!r}")

rows = verticals.get("vertical") or []
md_row = next((r for r in rows if isinstance(r, dict) and r.get("id") == "md_lennard_jones"), None)
if not md_row:
    errors.append("verticals.toml: missing md_lennard_jones row")
else:
    notes = str(md_row.get("notes", ""))
    for token in ("lammps", "md_oracle.toml", "run_oracle_stub"):
        if token not in notes.lower() and token not in notes:
            errors.append(f"md_lennard_jones notes must mention {token!r}")

oracle_rows = oracle.get("oracle") or []
ids = {r.get("id") for r in oracle_rows if isinstance(r, dict)}
for oid in ("lammps_lj_micro", "gromacs_lj_micro"):
    if oid not in ids:
        errors.append(f"md_oracle.toml missing {oid}")
    lammps_row = next((r for r in oracle_rows if r.get("id") == oid), {})
    if lammps_row.get("csv_lang") not in ("lammps", "gromacs"):
        errors.append(f"{oid}: csv_lang must be lammps or gromacs")

if "external/README.md" not in catalog and "run_oracle_stub.sh" not in catalog:
    errors.append("catalog must cite external driver doc or run_oracle_stub.sh")
if "lammps_lj_micro" not in catalog:
    errors.append("catalog md_lennard_jones must mention lammps_lj_micro")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("md-oracle-driver-doc: ok")
PY

li_ok "MD oracle driver doc"
