#!/usr/bin/env bash
# CI-friendly gate: MD external oracle JSON + registry path + Li checksum.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/ph-sci-md-oracle-competitive.json"
REGISTRY="$ROOT/benchmarks/competitive/ph-sci-md-oracle.toml"

bash scripts/bench-ph-sci-md-oracle-competitive.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }
[[ -f "$REGISTRY" ]] || { echo "missing $REGISTRY"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

out = Path("benchmarks/results/ph-sci-md-oracle-competitive.json")
registry = Path("benchmarks/competitive/ph-sci-md-oracle.toml")
doc = json.loads(out.read_text())
rows = doc.get("rows") or []
if not rows:
    print("no competitive rows")
    sys.exit(1)
if doc.get("gate_script") != "scripts/ph-sci-md-oracle-competitive-gates.sh":
    print("gate_script mismatch in JSON")
    sys.exit(1)
if doc.get("registry_path") != str(registry):
    print("registry_path mismatch")
    sys.exit(1)
row = rows[0]
if row.get("algo_registry_name") != "md_oracle_external":
    print("expected md_oracle_external row")
    sys.exit(1)
li = row.get("li") or {}
if not li.get("energy_drift_checksum"):
    print("missing li energy_drift_checksum")
    sys.exit(1)
drift = float(li["energy_drift_checksum"])
if not (0.0 < drift < 1.0e-3):
    print(f"li drift checksum out of range: {drift}")
    sys.exit(1)
comps = {c.get("id"): c for c in row.get("competitors") or []}
lammps = comps.get("lammps") or {}
if lammps.get("executed"):
    if lammps.get("energy_drift_checksum") is None:
        print("lammps executed but missing drift checksum")
        sys.exit(1)
    print(
        "lammps drift:",
        lammps.get("energy_drift_checksum"),
        "parity_gate_pass=",
        row.get("parity_gate_pass"),
    )
elif lammps.get("note"):
    print("lammps skipped:", lammps.get("note"))
else:
    print("lammps not executed — install lammps for external oracle")
print("ph-sci-md-oracle-competitive-gates OK")
PY
