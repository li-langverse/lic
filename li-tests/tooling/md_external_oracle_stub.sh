#!/usr/bin/env bash
# Gate: md_lennard_jones external oracle stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=llvm-env.sh
source "$ROOT/scripts/llvm-env.sh" 2>/dev/null || true
export CC="${CC:-clang-22}"
export CXX="${CXX:-clang++-22}"
STUB="$ROOT/benchmarks/tier2_physics/md_lennard_jones/external/run_oracle_stub.sh"
MANIFEST="$ROOT/benchmarks/results/md_lennard_jones/oracle_stub.json"

chmod +x "$STUB"
"$STUB"

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
print("md_external_oracle_stub: ok")
PY
