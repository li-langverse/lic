#!/usr/bin/env python3
"""Reproduce chem-r2 SCF gap tables (H2O, B3LYP, cc-pVDZ).

Requires: pip install pyscf
Run from repo root:
  python3 scripts/chem-r2-dft-scf-gap-ref.py

Emits two CSV sections:
  1) grid_level,N_grid,scf_iters,energy_ha,delta_mha_vs_grid5
  2) conv_tol,scf_iters,energy_ha,delta_mha_vs_1e-10
Geometry matches chem-r1 (Psi4 tutorial Z-matrix).
"""
from __future__ import annotations

import sys
import time

BASIS = "cc-pvdz"
XC = "b3lyp"
GRID_LEVELS = (1, 3, 5)
CONV_TOLS = (1e-6, 1e-8, 1e-10)


def _h2o_mol(gto_mod):
    return gto_mod.M(
        atom="O 0 0 0; H 0 0.757160 0.586260; H 0 -0.757160 0.586260",
        basis=BASIS,
        verbose=0,
    )


def grid_scaling(dft_mod, gto_mod) -> int:
    from pyscf import dft  # noqa: F401

    anchor_e: float | None = None
    rows: list[tuple[int, int, int, float, float]] = []
    mol = _h2o_mol(gto_mod)

    for level in GRID_LEVELS:
        mf = dft_mod.RKS(mol)
        mf.xc = XC
        mf.grids.level = level
        mf.conv_tol = 1e-10
        t0 = time.perf_counter()
        energy = float(mf.kernel())
        _ = time.perf_counter() - t0
        n_grid = int(getattr(mf.grids, "size", 0) or 0)
        iters = int(getattr(mf, "cycles", 0) or 0)
        rows.append((level, n_grid, iters, energy, 0.0))
        if level == GRID_LEVELS[-1]:
            anchor_e = energy

    if anchor_e is None:
        print("grid anchor missing", file=sys.stderr)
        return 1

    print("# grid_level,N_grid,scf_iters,energy_ha,delta_mha_vs_grid5")
    for level, n_grid, iters, energy, _ in rows:
        dmha = (energy - anchor_e) * 1000.0
        print(f"{level},{n_grid},{iters},{energy:.10f},{dmha:.4f}")
    return 0


def conv_scaling(dft_mod, gto_mod) -> int:
    anchor_e: float | None = None
    rows: list[tuple[float, int, float]] = []
    mol = _h2o_mol(gto_mod)

    for tol in CONV_TOLS:
        mf = dft_mod.RKS(mol)
        mf.xc = XC
        mf.grids.level = 3
        mf.conv_tol = tol
        energy = float(mf.kernel())
        iters = int(getattr(mf, "cycles", 0) or 0)
        rows.append((tol, iters, energy))
        if tol == CONV_TOLS[-1]:
            anchor_e = energy

    if anchor_e is None:
        print("conv anchor missing", file=sys.stderr)
        return 1

    print("# conv_tol,scf_iters,energy_ha,delta_mha_vs_1e-10")
    for tol, iters, energy in rows:
        dmha = (energy - anchor_e) * 1000.0
        print(f"{tol:g},{iters},{energy:.10f},{dmha:.4f}")
    return 0


def main() -> int:
    try:
        from pyscf import dft, gto  # type: ignore
    except ImportError:
        print(
            "pyscf not installed; install with: python3 -m pip install pyscf",
            file=sys.stderr,
        )
        return 2

    if grid_scaling(dft, gto) != 0:
        return 1
    if conv_scaling(dft, gto) != 0:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
