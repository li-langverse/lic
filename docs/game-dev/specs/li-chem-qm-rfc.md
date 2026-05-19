# RFC: li-chem — DFT, ab initio, TDDFT, AI-QM (PH-QM)

**Status:** Draft  
**Track:** PH-QM  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Gameplay `physics.chem` ≠ quantum chemistry. Users need easy, fast, provable QM APIs in Li.

## Proposal

New package **`li-chem`** (`import chem.dft`, `chem.tddft`, `chem.ml`).

```li
def run_dft(geometry: Geometry, basis: str, method: str) -> DftResult
  requires geometry_valid(geometry)
=
  ...
```

| Backend | Role |
|---------|------|
| native | Proved stubs, CI |
| gpu | LKIR grids |
| orca_trusted / psi4_trusted | Production accuracy |

**`chem.ml`:** surrogates, delta-learning (PH-ML async); filters proved in Li.

## Compliance

**CRITICAL** tier — SBOM, traceability `PKG-li-chem`.

## Note

Do not overload `li-physics-chem` (reaction networks for games).
