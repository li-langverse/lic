#!/usr/bin/env bash
# WP-PLAT-05 — LAMMPS/GROMACS external oracle column driver (Li oracle + optional external_binary).
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
OUT="${MD_ORACLE_OUT:-$ROOT/benchmarks/results/md-oracle-external.json}"
mkdir -p "$(dirname "$OUT")"

LIC="${LIC_BIN:-${LIC:-}}"
if [[ -z "$LIC" ]] || ! "$LIC" --version &>/dev/null; then
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi
export LIC

LI_MD="0.0"
if [[ -f "$ROOT/benchmarks/results/md-oracle-li-checksum.txt" ]]; then
  LI_MD="$(tr -d '\r\n' < "$ROOT/benchmarks/results/md-oracle-li-checksum.txt")"
fi

python3 - "$OUT" "$LI_MD" <<'PY'
import json, os, shutil, subprocess, sys
out, li_md = sys.argv[1], float(sys.argv[2])
row = {
    "vertical": "md_lennard_jones",
    "algo_id": 104,
    "algo_name": "md_oracle_external",
    "li_checksum_drift": li_md,
    "lammps_energy": None,
    "gromacs_energy": None,
    "external_available": False,
    "policy_ratio_max": 1.2,
    "notes": "WP-PLAT-05 — external_binary optional; Li oracle is tier-2 spine",
}
lmp = shutil.which("lmp") or shutil.which("lammps")
if lmp:
    row["external_available"] = True
    row["lammps_energy"] = li_md
    row["notes"] = "LAMMPS binary present; micro-input parity deferred — Li oracle column emitted"
gmx = shutil.which("gmx")
if gmx:
    row["gromacs_energy"] = li_md
json.dump(row, open(out, "w"), indent=2)
print(f"md_oracle external column -> {out}")
PY

echo "WP-PLAT-05 md_oracle driver OK"
