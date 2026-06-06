#!/usr/bin/env bash
# Gate: md_lennard_jones external oracle stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MANIFEST="$ROOT/benchmarks/results/md-external-oracle-stub.json"

chmod +x "$ROOT/scripts/bench-md-external-oracle-stub.sh"
chmod +x "$ROOT/scripts/check-md-oracle.sh"
"$ROOT/scripts/bench-md-external-oracle-stub.sh"

[[ -f "$MANIFEST" ]] || { echo "missing $MANIFEST"; exit 1; }
python3 - <<'PY' "$MANIFEST"
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())
assert data.get("mode") == "stub_ok", data
assert data.get("oracle_registry") == "benchmarks/competitive/md_oracle.toml", data
assert "lammps_lj_micro" in data.get("oracle_ids", []), data
assert "gromacs_lj_micro" in data.get("oracle_ids", []), data
assert data.get("validity_gate_pass") is True, data
print("md_external_oracle_stub: ok")
PY
