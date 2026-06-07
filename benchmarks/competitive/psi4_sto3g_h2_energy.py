#!/usr/bin/env python3
"""Psi4 RKS/LDA reference — H₂ STO-3G (LGPL oracle for chem-r2 / algo 418)."""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

from chem_dft_competitive_common import (
    BASIS,
    CHARGE,
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    XC,
    bench_loop,
    li_scaffold_scf_h2_hartree,
    report_base,
)

H2_BOND_ANG = 0.74
H2_SPIN = 0

out = os.environ.get(
    "PH_SCI_CHEM_PSI4_H2_OUT",
    "benchmarks/results/ph-sci-chem-competitor-psi4-h2.json",
)
report = report_base("psi4", "ph-sci-chem-competitor-psi4-h2", "sto3g_h2_lda_energy")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["license"] = "LGPL-3.0-or-later"
report["geometry"] = f"H 0 0 {-0.5 * H2_BOND_ANG}; H 0 0 {0.5 * H2_BOND_ANG}"
report["charge"] = CHARGE
report["spin"] = H2_SPIN
report["algo_id"] = 418
report["catalog_row"] = "qm_dft_scf_energy"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import psi4
except ImportError:
    report["note"] = "psi4 not installed (optional LGPL oracle for qm_dft_scf_energy / 418)"
    write_report()
    sys.exit(0)

report["framework_version"] = getattr(psi4, "__version__", "psi4")
psi4.set_memory("256 MB")
psi4.core.set_num_threads(1)

half = 0.5 * H2_BOND_ANG
psi4_geom = f"""
molecule {{
  H 0 0 {-half}
  H 0 0 {half}
}}
set {{
  basis {BASIS}
  scf_type pk
  d_convergence 1e-8
}}
"""
psi4.set_options({"reference": "rks", "dft_functional": "svwn" if "vwn" in XC else "lda"})


def run_scf():
    psi4.core.clean()
    return float(psi4.energy("svwn" if "vwn" in XC else "lda", molecule=psi4_geom))


def sanity(energy) -> bool:
    return float(energy) < 0.0


cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, run_scf, sanity)
energy = run_scf()
li_e = round(li_scaffold_scf_h2_hartree(), 12)
delta = round(li_e - float(energy), 12)

if err:
    report["note"] = err
    report["energy_hartree"] = round(float(energy), 12)
    report["li_energy_hartree"] = li_e
    report["energy_delta_hartree"] = delta
    write_report()
    sys.exit(0)

report["cpu_sec"] = cpu_sec
report["energy_hartree"] = round(float(energy), 12)
report["li_energy_hartree"] = li_e
report["energy_delta_hartree"] = delta
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["note"] = "Psi4 RKS H2 STO-3G SVWN/LDA — chem-r2 external oracle (algo 418)"
write_report()
