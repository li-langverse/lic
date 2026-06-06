#!/usr/bin/env bash
# Gate: md_oracle_external stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DRIVER="$ROOT/benchmarks/harness/md_external_oracle.py"
MANIFEST="$ROOT/benchmarks/results/md_oracle_external/oracle_stub.json"

python3 "$DRIVER" --engine lammps --dry-run

[[ -f "$MANIFEST" ]] || { echo "missing $MANIFEST"; exit 1; }
python3 - <<'PY' "$MANIFEST"
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())
assert data.get("mode") == "stub_ok", data
assert data.get("driver") == "benchmarks/harness/md_external_oracle.py", data
assert "lammps_lj_micro" in data.get("oracle_ids", []), data
print("md_external_oracle_stub: ok")
PY
