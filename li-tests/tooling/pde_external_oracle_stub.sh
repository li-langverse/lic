#!/usr/bin/env bash
# Gate: pde_heat_implicit_jacobi external oracle stub manifest (no PETSc/hypre required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STUB="$ROOT/benchmarks/tier2_physics/pde_oracle_external/run_oracle_stub.sh"
MANIFEST="$ROOT/benchmarks/results/pde_heat_implicit_jacobi/oracle_stub.json"

chmod +x "$STUB"
"$STUB" --engine petsc_hypre --dry-run

[[ -f "$MANIFEST" ]] || { echo "missing $MANIFEST"; exit 1; }
python3 - <<'PY' "$MANIFEST"
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())
assert data.get("mode") == "stub_ok", data
assert "petsc_hypre_heat_implicit" in data.get("oracle_ids", []), data
print(f"pde_external_oracle_stub: ok ({path})")
PY
