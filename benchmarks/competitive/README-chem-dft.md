# Chem DFT competitive benchmark

Compare **Li `chem_dft_energy_kernel_hartree()`** (mini STO-3G radial-grid scaffold in `packages/li-chem/src/lib.li`) against license-friendly QM references.

## Run

```bash
# From lic repo root (WSL recommended for lic build)
pip install --user --break-system-packages -r scripts/requirements-ph-sci-chem-dft-competitive.txt
bash scripts/bench-ph-sci-chem-dft-competitive.sh
# CI gate (install + bench + JSON checks)
bash scripts/ph-sci-chem-dft-competitive-gates.sh
```

Output: `benchmarks/results/ph-sci-chem-dft-competitive.json`

## Methodology

| Field | Value |
|-------|-------|
| Geometry | `H 0 0 0` (single H atom) |
| Basis | `sto-3g` |
| XC | `lda,vwn` (PySCF); Li uses Slater LDA on grid (`-0.738558 * rho^(1/3)`) |
| Li kernel | 8-point radial grid, contracted mini STO-3G, kin/pot/LDA/Hartree — **not** full Gaussian ERIs |
| PySCF | `dft.RKS` converged SCF — **primary OSS oracle** (Apache-2.0) |
| Psi4 | Optional `svwn` when installed (LGPL) |
| ORCA | **External manual oracle only** — not redistributable; do not vendor binaries in CI |

## License notes

- **PySCF** — Apache-2.0; bundled via pip in gate script.
- **Psi4** — LGPL; optional competitor row (`executed: false` when absent).
- **ORCA** — Academic free; **cannot** ship in CI. Run locally and merge energy into JSON or record in lab notes:

```bash
# Example user workflow (ORCA 6.x) — not automated in repo
! RKS LDA SVWN
* sto-3g
{charge 0 mult 2}
H 0 0 0
*
```

Import pattern: set `competitors[id=orca].energy_hartree` and `executed: true` in `ph-sci-chem-dft-competitive.json` after manual run.

## Expected parity gaps

Li scaffold energy is typically **~1–2 Hartree** away from PySCF STO-3G LDA because:

1. Li uses a fixed radial quadrature, not analytic Gaussian integrals.
2. Li density is built from a single basis coefficient vector, not self-consistent Gaussian MOs.
3. Hartree/Coulomb are 2-center centroid approximations on the grid.

`parity_gate_pass` uses `energy_tolerance_hartree` (0.35) in `ph-sci-chem-dft.toml` — expect **false** until full DFT parity (CHEM-04+). Timing `ratio_vs_li` is still reported when both sides execute.

## Files

| Path | Role |
|------|------|
| `scripts/bench-ph-sci-chem-dft-competitive.sh` | Orchestrator + JSON merge |
| `scripts/bench-ph-sci-chem-dft-li.sh` | Li build/run timing |
| `benchmarks/competitive/pyscf_sto3g_h_energy.py` | PySCF driver |
| `benchmarks/competitive/psi4_sto3g_h_energy.py` | Psi4 driver (optional) |
| `benchmarks/competitive/chem_dft_competitive_common.py` | Shared workload + Li mirror |
| `benchmarks/competitive/ph-sci-chem-dft.toml` | Registry / tier-2 gate |
