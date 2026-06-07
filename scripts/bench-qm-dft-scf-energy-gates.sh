#!/usr/bin/env bash
# CI gate for chem-r2 qm_dft_scf_energy (418): validity harness + optional Psi4 oracle.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${QM_DFT_SCF_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/qm_dft_scf_energy-harness.json"

if [[ "${QM_DFT_SCF_SKIP_PIP:-0}" != "1" ]]; then
  python3 -m pip install --user --break-system-packages \
    -r scripts/requirements-ph-sci-chem-dft-competitive.txt >/dev/null 2>&1 || true
fi

bash scripts/bench-qm-dft-scf-energy.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

out = Path("benchmarks/results/qm_dft_scf_energy-harness.json")
doc = json.loads(out.read_text())
axes = doc.get("axes") or {}
validity = axes.get("validity") or {}
li = doc.get("li") or {}

if not li.get("energy_hartree"):
    print("missing li energy_hartree")
    sys.exit(1)

if not validity.get("li_energy_lt_zero"):
    print("validity failed: li energy must be < 0 Ha")
    sys.exit(1)

oracle_id = validity.get("oracle_id")
if oracle_id:
    comp = (doc.get("competitors") or {}).get(oracle_id) or {}
    if not comp.get("executed"):
        print(f"{oracle_id} marked oracle but not executed")
        sys.exit(1)
    if comp.get("energy_hartree") is None:
        print(f"{oracle_id} missing energy_hartree")
        sys.exit(1)
    print(
        "validity OK:",
        f"oracle={oracle_id}",
        f"li_e={li['energy_hartree']}",
        f"ref_e={comp['energy_hartree']}",
        f"delta={axes.get('accuracy', {}).get('energy_delta_hartree')}",
    )
else:
    psi4 = (doc.get("competitors") or {}).get("psi4") or {}
    print("warn: no oracle executed —", psi4.get("note") or "install psi4/pyscf")

if doc.get("threshold_ratio_cpp_locked") is not True:
    print("threshold_ratio_cpp must remain locked")
    sys.exit(1)

print("bench-qm-dft-scf-energy-gates OK")
PY
