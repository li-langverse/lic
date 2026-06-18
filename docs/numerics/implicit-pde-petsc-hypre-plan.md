# Implicit PDE stack — PETSc + hypre BoomerAMG (lic#108)

**Status:** plan slice shipped (2026-06-08)  
**PH:** PH-5b · **G-math:** scalable LA beyond dense tier-1  
**Related:** [lic#28](https://github.com/li-langverse/lic/issues/28) (PETSc–Kokkos execution), [lic#33](https://github.com/li-langverse/lic/issues/33) (vendor pin policy)

## Target reference stack

Tier-2 implicit PDE rows (`pde_heat_implicit_jacobi`, future `fea_solver_iterative`) stage against the exascale PETSc + hypre pattern:

```text
DM (mesh / DOF layout)
  → SNES (nonlinear residual) or KSP-only (linear implicit step)
    → KSP (Krylov: GMRES / CG)
      → PC (preconditioner)
        → hypre BoomerAMG (CPU / GPU host path)
        → PCBJKOKKOS (GPU batched block Jacobi, PETSc 3.25+)
```

| Layer | Reference | Li slice (this PR) |
|-------|-----------|-------------------|
| Mesh | `DMDACreate2d` / `DMPlex` | Fixed 8-cell 1D scaffold in `physics.fluids` |
| Assembly | `MatSetValues` / `MatAssemblyBegin` | **Assembled** Jacobi stencil (`jacobi_heat_implicit_assembled_step`) |
| Matrix-free | `MatShell` + `MatMult` callback | **Matrix-free** Laplacian apply (`heat_implicit_matvec_1d`) |
| Solve | `KSPSolve` + `PCHYPRE` BoomerAMG | Li Jacobi oracle checksum; vendor oracle stub |
| GPU PC | `PCBJKOKKOS` | Documented watch row; not bundled in CI |

External signals (pinned in `benchmarks/competitive/ph-sci-pde-implicit.toml`):

- [PCBJKOKKOS](https://petsc.org/release/manualpages/PC/PCBJKOKKOS/) — PETSc 3.25 GPU batched preconditioner
- [ALCF PETSc exascale](https://www.alcf.anl.gov/news/optimizing-petsc-exascale)
- [Frontier PETSc+Kokkos tuning](https://lists.mcs.anl.gov/pipermail/petsc-users/2024-June/050848.html)

## Minimal Li API surface (`pde_heat_implicit_jacobi`)

Catalog row **algo_id 204** (`scripts/build_algo_registry.py`). Tier-2 C harness uses 64×64 Jacobi (`scripts/gen_wp3_tier2_harnesses.py`); Li package exposes a **provable 8-cell 1D** slice:

| Mode | Entry | Contract |
|------|-------|----------|
| Assembled | `jacobi_heat_implicit_assembled_step` | One Jacobi sweep on stored `b`, writes `x` |
| Matrix-free | `heat_implicit_matvec_1d` | `y = (I - r·L) x` without storing `L` |
| Oracle | `pde_implicit_jacobi_oracle_checksum` | Deterministic checksum for competitive JSON + smokes |

Full 2D distributed meshes and BoomerAMG remain **vendor oracle** rows (`workload_class = stub`) until PH-7e portable execution + proof story attach to KSP callbacks.

## Bench policy (aligned with lic#33)

Vendor oracle versions are pinned in TOML — same pattern as Eigen baseline (#33) and PySCF chem DFT:

| Oracle | Pin | License | CI |
|--------|-----|---------|-----|
| PETSc | 3.25.x | BSD-2 | Optional — skip when `PETSC_DIR` unset |
| hypre | 2.32.x | Apache-2.0 / LGPL | Via PETSc external packages |
| Li Jacobi | package version | Apache-2.0 | Always — `bench-ph-sci-pde-implicit-competitive.sh` |

Run:

```bash
bash scripts/ph-sci-pde-implicit-competitive-gates.sh
```

Output: `benchmarks/results/ph-sci-pde-implicit-competitive.json`

## Roadmap (deferred)

1. **B1** — PETSc `DMDA` + `KSP` driver script (user-run, not redistributable binaries)
2. **B2** — `PCHYPRE` BoomerAMG checksum column in tier-2 CSV
3. **B3** — Pure-Li Krylov + AMG proof slice (after P-linalg float matvec)
