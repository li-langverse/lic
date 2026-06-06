#!/usr/bin/env bash
# CI-friendly gate: MD external oracle stub JSON + md_oracle.toml + verticals honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/md_lennard_jones/oracle_stub.json"
REGISTRY="$ROOT/benchmarks/competitive/md_oracle.toml"

bash scripts/bench-ph-sci-md-oracle-competitive.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }
[[ -f "$REGISTRY" ]] || { echo "missing $REGISTRY"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

import tomllib

out = Path("benchmarks/results/md_lennard_jones/oracle_stub.json")
doc = json.loads(out.read_text())
if doc.get("mode") != "stub_ok":
    print("manifest mode must be stub_ok:", doc.get("mode"))
    sys.exit(1)
drift = doc.get("reference_energy_drift")
if drift is None or float(drift) <= 0.0 or float(drift) >= 1.0e-3:
    print("reference_energy_drift out of expected Li micro range:", drift)
    sys.exit(1)
oracle_ids = doc.get("oracle_ids") or []
for required in ("lammps_lj_micro", "gromacs_lj_micro"):
    if required not in oracle_ids:
        print("missing oracle id:", required)
        sys.exit(1)
if doc.get("gate_script") != "scripts/ph-sci-md-oracle-competitive-gates.sh":
    print("manifest gate_script mismatch")
    sys.exit(1)
if doc.get("li_tests") != "li-tests/tooling/md_external_oracle_stub.sh":
    print("manifest li_tests mismatch")
    sys.exit(1)

registry = tomllib.loads(Path("benchmarks/competitive/md_oracle.toml").read_text())
harness = registry.get("harness") or {}
if harness.get("gate_script") != "scripts/ph-sci-md-oracle-competitive-gates.sh":
    print("md_oracle.toml gate_script mismatch")
    sys.exit(1)
if harness.get("li_tests") != "li-tests/tooling/md_external_oracle_stub.sh":
    print("md_oracle.toml li_tests mismatch")
    sys.exit(1)

vert = tomllib.loads(Path("benchmarks/competitive/verticals.toml").read_text())
md_vert = next((v for v in vert.get("vertical", []) if v.get("id") == "md_lennard_jones"), None)
if not md_vert:
    print("verticals.toml missing md_lennard_jones row")
    sys.exit(1)
if md_vert.get("oracle") != "external_binary":
    print("verticals.toml md_lennard_jones oracle must be external_binary")
    sys.exit(1)
if md_vert.get("workload_class") != "v0_micro":
    print("verticals.toml md_lennard_jones workload_class must be v0_micro")
    sys.exit(1)

print(
    "md_lj_micro_oracle parity:",
    "reference_drift=",
    drift,
    "parity_gate_pass=false (stub honesty)",
)
print("verticals.toml md_lennard_jones external_binary/v0_micro OK")
print("ph-sci-md-oracle-competitive-gates OK")
PY
