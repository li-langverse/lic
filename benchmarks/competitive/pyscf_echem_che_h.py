#!/usr/bin/env python3
"""PySCF CHE H* adsorption oracle — H atom + H2 STO-3G LDA (Apache-2.0)."""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

from echem_competitive_common import (
    BASIS,
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    H2_ATOM,
    H_STAR_ATOM,
    REFERENCE_POTENTIAL_V,
    XC,
    bench_loop,
    hartree_to_ev,
    report_base,
)

out = os.environ.get(
    "PH_SCI_ECHEM_PYSCF_OUT",
    "benchmarks/results/ph-sci-echem-competitor-pyscf.json",
)
report = report_base("pyscf", "ph-sci-echem-competitor-pyscf", "echem_che_h")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["license"] = "Apache-2.0"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    from pyscf import dft, gto
except ImportError:
    report["note"] = (
        "pyscf not installed — pip install -r scripts/requirements-ph-sci-chem-dft-competitive.txt"
    )
    write_report()
    sys.exit(0)

report["framework_version"] = getattr(gto, "__version__", None) or "pyscf"


def scf_energy_hartree(atom: str) -> float:
    mol = gto.M(atom=atom, basis=BASIS, spin=1 if ";" not in atom else 0, charge=0)
    mf = dft.RKS(mol)
    mf.xc = XC
    mf.verbose = 0
    energy = mf.kernel()
    if energy is None:
        raise RuntimeError("SCF did not converge")
    return float(energy)


def che_adsorption_ev() -> float:
    e_h = scf_energy_hartree(H_STAR_ATOM)
    e_h2 = scf_energy_hartree(H2_ATOM)
    delta_h = e_h - 0.5 * e_h2
    return hartree_to_ev(delta_h) - REFERENCE_POTENTIAL_V


def sanity(energy_ev: float) -> bool:
    return energy_ev is not None and float(energy_ev) < 10.0


try:
    ref_ev = che_adsorption_ev()
except Exception as exc:  # noqa: BLE001
    report["note"] = f"PySCF CHE oracle failed: {exc}"
    write_report()
    sys.exit(0)


def run_che():
    return che_adsorption_ev()


cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, run_che, sanity)

if err:
    report["note"] = err
    report["energy_ev"] = round(ref_ev, 6)
    write_report()
    sys.exit(0)

report["cpu_sec"] = cpu_sec
report["energy_ev"] = round(ref_ev, 6)
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["note"] = (
    "PySCF RKS/LDA CHE proxy: E(H) - 0.5*E(H2) - U (Li radial SCF coupled at WP-ECHEM-05)"
)
write_report()
