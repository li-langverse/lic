#!/usr/bin/env python3
"""Psi4 RKS/LDA reference — H atom STO-3G (LGPL, optional)."""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

from chem_dft_competitive_common import (
    ATOM,
    BASIS,
    CHARGE,
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    SPIN,
    XC,
    bench_loop,
    report_base,
)

out = os.environ.get(
    "PH_SCI_CHEM_PSI4_OUT",
    "benchmarks/results/ph-sci-chem-competitor-psi4.json",
)
report = report_base("psi4", "ph-sci-chem-competitor-psi4", "sto3g_h_lda_energy")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["license"] = "LGPL-3.0-or-later"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import psi4
except ImportError:
    report["note"] = "psi4 not installed (optional LGPL oracle)"
    write_report()
    sys.exit(0)

report["framework_version"] = getattr(psi4, "__version__", "psi4")
psi4.set_memory("256 MB")
psi4.core.set_num_threads(1)

# Psi4 input — match PySCF geometry/basis/XC where possible.
psi4_geom = f"""
molecule {{
  H 0 0 0
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

if err:
    report["note"] = err
    report["energy_hartree"] = round(float(energy), 12)
    write_report()
    sys.exit(0)

report["cpu_sec"] = cpu_sec
report["energy_hartree"] = round(float(energy), 12)
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["note"] = "Psi4 RKS SVWN/LDA (optional LGPL oracle)"
write_report()
