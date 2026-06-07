#!/usr/bin/env bash
# Li native echem_che_h_adsorption_energy timing (stub oracle at U=0).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_ECHEM_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

OUT="$BENCHMARKS_RESULTS/ph-sci-echem-li.json"
T0=$(date +%s.%N)

python3 <<'PY'
import json
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, "benchmarks/competitive")
from echem_competitive_common import (
    REFERENCE_POTENTIAL_V,
    bench_loop,
    li_echem_che_h_adsorption_energy_ev,
)

runs = 64
warmup = 4


def run():
    return li_echem_che_h_adsorption_energy_ev(REFERENCE_POTENTIAL_V)


cpu_sec, err = bench_loop(runs, warmup, run, lambda e: e < 0.0)
energy_ev = li_echem_che_h_adsorption_energy_ev(REFERENCE_POTENTIAL_V)
out = Path(os.environ.get("BENCHMARKS_RESULTS", "benchmarks/results")) / "ph-sci-echem-li.json"
doc = {
    "suite": "ph-sci-echem-li",
    "workload": "echem_che_h",
    "executed": err is None,
    "cpu_sec": cpu_sec,
    "energy_ev": round(energy_ev, 6),
    "energy_source": "li_echem_dft_scf_mirror",
    "validity_gate_pass": energy_ev < 0.0,
    "validity_ratio": 1.0 if energy_ev < 0.0 else 0.0,
    "potential_v": REFERENCE_POTENTIAL_V,
    "note": "Li echem_che_h_adsorption_energy from chem_dft SCF (WP-ECHEM-05)",
}
if err:
    doc["note"] = err
out.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
print(out)
PY

T1=$(date +%s.%N)
python3 -c "import json; p='$OUT'; d=json.loads(open(p).read()); d['wall_cpu_sec']=round(float('$T1')-float('$T0'),6); open(p,'w').write(json.dumps(d,indent=2)+'\n')"
echo "bench-ph-sci-echem-li: done"
