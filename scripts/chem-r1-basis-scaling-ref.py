#!/usr/bin/env python3
"""Reproduce chem-r1 basis cost/accuracy table (H2O, B3LYP).

Requires: pip install pyscf
Run from repo root:
  python3 scripts/chem-r1-basis-scaling-ref.py

Outputs CSV rows: basis,N_basis,wall_s,energy_ha,grid_points
Geometry matches Psi4 tutorial Z-matrix (O–H 0.96 Å, angle 104.5°).
"""
from __future__ import annotations

import sys
import time

BASES = ("sto-3g", "6-31g", "6-31g*", "cc-pvdz", "cc-pvtz")
ANCHOR = "cc-pvtz"


def main() -> int:
    try:
        from pyscf import dft, gto  # type: ignore
    except ImportError:
        print(
            "pyscf not installed; install with: python3 -m pip install pyscf",
            file=sys.stderr,
        )
        return 2

    mol = gto.M(
        atom="O 0 0 0; H 0 0.757160 0.586260; H 0 -0.757160 0.586260",
        basis=BASES[0],
        verbose=0,
    )
    anchor_e: float | None = None
    rows: list[tuple[str, int, float, float, int]] = []

    for basis in BASES:
        mol.basis = basis
        mf = dft.RKS(mol)
        mf.xc = "b3lyp"
        mf.grids.level = 3
        t0 = time.perf_counter()
        energy = float(mf.kernel())
        wall = time.perf_counter() - t0
        n_basis = int(mf.mo_coeff.shape[1])
        n_grid = int(getattr(mf.grids, "size", 0) or 0)
        rows.append((basis, n_basis, wall, energy, n_grid))
        if basis == ANCHOR:
            anchor_e = energy

    if anchor_e is None:
        print("anchor basis missing", file=sys.stderr)
        return 1

    sto_wall = rows[0][2] or 1e-9
    print("basis,N_basis,rel_wall,energy_ha,delta_mha_vs_cc-pvtz,grid_points")
    for basis, n_basis, wall, energy, n_grid in rows:
        rel = wall / sto_wall
        dmha = (energy - anchor_e) * 1000.0
        print(f"{basis},{n_basis},{rel:.4f},{energy:.10f},{dmha:.3f},{n_grid}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
