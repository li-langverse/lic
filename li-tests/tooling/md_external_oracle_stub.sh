#!/usr/bin/env bash
# Gate: md_lennard_jones external oracle stub manifest (no LAMMPS/GROMACS required).
# Cites: benchmarks/competitive/md_oracle.toml, scripts/md-external-oracle-stub.py
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STUB="$ROOT/scripts/md-external-oracle-stub.py"
MANIFEST="$ROOT/benchmarks/results/md_lennard_jones/oracle_stub.json"
ORACLE_TOML="$ROOT/benchmarks/competitive/md_oracle.toml"

[[ -f "$ORACLE_TOML" ]] || { echo "missing $ORACLE_TOML"; exit 1; }
chmod +x "$STUB"
python3 "$STUB"

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
assert data.get("oracle_registry") == "benchmarks/competitive/md_oracle.toml", data
assert data.get("gate_script") == "scripts/md-external-oracle-stub.py", data
print("md_external_oracle_stub: ok")
PY
