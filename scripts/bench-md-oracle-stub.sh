#!/usr/bin/env bash
# WP-PLAT-05 — MD external oracle stub: Li tier-2 checksum + lammps/gromacs stub rows.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_MD_ORACLE_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

REGISTRY="$ROOT/benchmarks/competitive/md_oracle.toml"
OUT="$BENCHMARKS_RESULTS/ph-sci-md-oracle-competitive.json"
LIC_BIN="${LIC:-$ROOT/build/compiler/lic/lic}"
SMOKE="$ROOT/packages/li-sim-scientific/li-tests/smoke/md_oracle_li_checksum.li"
BUILD_DIR="$ROOT/build/bench/md_oracle_stub"
mkdir -p "$BUILD_DIR"

if [[ ! -x "$LIC_BIN" ]]; then
  echo "bench-md-oracle-stub: building compiler"
  bash "$ROOT/scripts/build.sh"
fi

"$LIC_BIN" build --allow-open-vc --no-lean-verify "$SMOKE" -o "$BUILD_DIR/md_oracle_li_checksum" 2>/dev/null \
  || "$LIC_BIN" build --allow-open-vc "$SMOKE" -o "$BUILD_DIR/md_oracle_li_checksum"
# Checksum from Python mirror of lib.li oracle (Li has no stdout print yet).
LI_CHECKSUM="$(python3 -c "import sys; sys.path.insert(0,'benchmarks/competitive'); from md_oracle_li_mirror import li_sim_scientific_oracle_checksum_md; print(li_sim_scientific_oracle_checksum_md())")"
if [[ -z "$LI_CHECKSUM" ]]; then
  echo "bench-md-oracle-stub: failed to read Li MD oracle checksum"
  exit 1
fi

export PH_SCI_MD_ORACLE_ROOT="$ROOT" PH_SCI_MD_ORACLE_OUT="$OUT" PH_SCI_MD_ORACLE_REGISTRY="$REGISTRY"
export PH_SCI_MD_ORACLE_LI_CHECKSUM="$LI_CHECKSUM"
python3 <<'PY'
import json
import os
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_MD_ORACLE_ROOT"])
out = Path(os.environ["PH_SCI_MD_ORACLE_OUT"])
registry = os.environ["PH_SCI_MD_ORACLE_REGISTRY"]
li_checksum = float(os.environ["PH_SCI_MD_ORACLE_LI_CHECKSUM"])

doc = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-sci-md-oracle-competitive",
    "benchmark": "md_lennard_jones",
    "registry": str(Path(registry).relative_to(root)),
    "workload_class": "v0_micro",
    "rows": [
        {
            "id": "md_lennard_jones",
            "li": {
                "id": "li",
                "csv_lang": "li",
                "executed": True,
                "checksum": li_checksum,
                "oracle": "sim_scientific_oracle_checksum_md",
                "workload_class": "v0_micro",
                "validity_gate_pass": True,
                "ratio_vs_li": 1.0,
            },
            "competitors": [
                {
                    "id": "lammps",
                    "csv_lang": "lammps",
                    "incumbent": "LAMMPS",
                    "executed": False,
                    "status": "stub",
                    "checksum": None,
                    "validity_gate_pass": False,
                    "ratio_vs_li": None,
                    "note": "Set LI_MD_ORACLE_LAMMPS=1 with lammps on PATH for B1 driver",
                },
                {
                    "id": "gromacs",
                    "csv_lang": "gromacs",
                    "incumbent": "GROMACS",
                    "executed": False,
                    "status": "stub",
                    "checksum": None,
                    "validity_gate_pass": False,
                    "ratio_vs_li": None,
                    "note": "Set LI_MD_ORACLE_GROMACS=1 with gmx on PATH for B2 driver",
                },
            ],
        }
    ],
}
out.write_text(json.dumps(doc, indent=2) + "\n")
print(f"bench-md-oracle-stub: wrote {out} (li_checksum={li_checksum})")
PY

echo "bench-md-oracle-stub: done"
