#!/usr/bin/env bash
# External MD oracle stub bench — records manifest without LAMMPS/GROMACS binaries.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ORACLE_TOML="$ROOT/benchmarks/competitive/md_oracle.toml"
OUT="${MD_EXTERNAL_ORACLE_OUT:-$ROOT/benchmarks/results/md-external-oracle-stub.json}"

bash "$ROOT/scripts/check-md-oracle.sh"

if [[ "${LI_MD_ORACLE_LAMMPS:-}" == "1" ]] && command -v lammps >/dev/null 2>&1; then
  echo "md external oracle: LAMMPS requested but B1 driver not implemented" >&2
  exit 2
fi
if [[ "${LI_MD_ORACLE_GROMACS:-}" == "1" ]] && command -v gmx >/dev/null 2>&1; then
  echo "md external oracle: GROMACS requested but B2 driver not implemented" >&2
  exit 2
fi

export ORACLE_TOML OUT ROOT
python3 - <<'PY'
import json
import os
import time
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

root = Path(os.environ["ROOT"])
oracle_toml = Path(os.environ["ORACLE_TOML"])
out = Path(os.environ["OUT"])
data = tomllib.loads(oracle_toml.read_text())
rows = data.get("oracle") or []
oracle_ids = [str(r["id"]) for r in rows if isinstance(r, dict) and "id" in r]

manifest = {
    "benchmark": data.get("meta", {}).get("benchmark", "md_lennard_jones"),
    "mode": "stub_ok",
    "oracle_registry": "benchmarks/competitive/md_oracle.toml",
    "plan": "docs/benchmarks/competitive-engines-plan.md",
    "gate_script": "scripts/check-md-oracle.sh",
    "li_test": "li-tests/tooling/md_external_oracle_stub.sh",
    "oracle_ids": oracle_ids,
    "reference": "sim_scientific_oracle_checksum_md() (Li internal oracle until B1/B2)",
    "workload_class": "v0_micro",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "validity_gate_pass": True,
}
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(f"wrote {out}")
PY

echo "bench-md-external-oracle-stub: ok"
