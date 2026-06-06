#!/usr/bin/env bash
# Gate: md_lennard_jones external oracle stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MANIFEST="$ROOT/benchmarks/results/md_lennard_jones/oracle_stub.json"

chmod +x "$ROOT/scripts/ph-sci-md-oracle-competitive-gates.sh"
"$ROOT/scripts/ph-sci-md-oracle-competitive-gates.sh"

[[ -f "$MANIFEST" ]] || { echo "missing $MANIFEST"; exit 1; }
python3 - <<'PY' "$MANIFEST"
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())
assert data.get("mode") == "stub_ok", data
assert data.get("reference_energy_drift"), data
assert "lammps_lj_micro" in data.get("oracle_ids", []), data
assert data.get("registry") == "benchmarks/competitive/md_oracle.toml", data
print("md_external_oracle_stub: ok")
PY
