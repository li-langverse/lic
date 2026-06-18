# PDE implicit PETSc/hypre plan slice (lic#108)

**Date:** 2026-06-08  
**PH / REQ:** PH-5b · G-math implicit PDE  
**Issue:** https://github.com/li-langverse/lic/issues/108

## Summary

Ships the plan-approved explorer checklist: target stack documentation (DM → SNES/KSP → hypre BoomerAMG), minimal Li API for catalog row `pde_heat_implicit_jacobi`, and vendor oracle version pins aligned with lic#33.

## Checklist (issue #108)

- [x] Document target stack — `docs/numerics/implicit-pde-petsc-hypre-plan.md`
- [x] Minimal Li API (assembled + matrix-free) — `packages/li-physics-fluids` v2
- [x] Bench policy with PETSc 3.25 / hypre 2.32 pins — `benchmarks/competitive/ph-sci-pde-implicit.toml`

## Gates

```bash
bash scripts/ph-sci-pde-implicit-competitive-gates.sh
bash scripts/check-hpc-competitive.sh
```

## Deferred

- B1 real PETSc `KSPSolve` + `PCHYPRE` driver (user-run)
- B2 tier-2 CSV column for hypre checksum
- B3 pure-Li Krylov + AMG proof slice
