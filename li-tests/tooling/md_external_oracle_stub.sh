#!/usr/bin/env bash
# Gate: md_lennard_jones external oracle stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MANIFEST="$ROOT/benchmarks/results/md_lennard_jones/oracle_stub.json"
REGISTRY="$ROOT/benchmarks/competitive/md_oracle.toml"

chmod +x "$ROOT/scripts/bench-md-oracle-external.sh"
"$ROOT/scripts/bench-md-oracle-external.sh"

[[ -f "$MANIFEST" ]] || { echo "missing $MANIFEST"; exit 1; }
[[ -f "$REGISTRY" ]] || { echo "missing $REGISTRY"; exit 1; }

python3 - <<'PY' "$MANIFEST" "$REGISTRY"
import json
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

manifest_path = Path(sys.argv[1])
registry_path = Path(sys.argv[2])
data = json.loads(manifest_path.read_text(encoding="utf-8"))
assert data.get("mode") == "stub_ok", data
assert data.get("algo_registry_id") == 104, data
assert "lammps_lj_micro" in data.get("oracle_ids", []), data
smoke = data.get("li_tests_smoke", "")
repo_root = manifest_path.parents[3]
assert smoke and (repo_root / smoke).is_file(), smoke
reg = tomllib.loads(registry_path.read_text(encoding="utf-8"))
gate = (reg.get("harness") or {}).get("gate_script", "")
assert gate.endswith("md_external_oracle_stub.sh"), gate
print("md_external_oracle_stub: ok")
PY
