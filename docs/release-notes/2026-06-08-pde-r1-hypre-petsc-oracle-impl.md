# PDE implicit PETSc+hypre oracle — implement slice (lic#108)

**Date:** 2026-06-08  
**Issue:** [#108](https://github.com/li-langverse/lic/issues/108)  
**Plan:** [2026-06-07-pde-r1-hypre-petsc-oracle-plan.md](../superpowers/plans/2026-06-07-pde-r1-hypre-petsc-oracle-plan.md)

## Shipped

- `benchmarks/harness/pde_external_oracle.py` — stub driver (`--dry-run` → `li_sim_summary_v1`)
- `benchmarks/tier2_physics/pde_oracle_external/` — README, PINNED.md, run_oracle_stub.sh
- `benchmarks/competitive/pde_oracle.toml` — version 1 stub_ok pins
- `benchmarks/competitive/registry.toml` — `petsc_hypre_heat_implicit` watch row
- `benchmarks/competitive/verticals.toml` — `pde_heat_2d` oracle honesty upgrade
- `packages/li-sim-scientific` — implicit PDE API sketch (matrix-free 1D laplacian + Jacobi step)
- `scripts/sim-algo-research-gates.sh` — `SIM_RESEARCH_VERTICAL=pde`
- `li-tests/tooling/pde_external_oracle_stub.sh` — gate script

## Deferred

- Real PETSc SNES/KSP + hypre solve (exit 2 when `PETSC_DIR` set)
- GPU `PCBJKOKKOS` column (lic#28)
- `verify.py --external-oracle` hook (benchmarks repo harness)

## Gates

```bash
./scripts/check-hpc-competitive.sh          # exit 0
./li-tests/tooling/pde_external_oracle_stub.sh  # exit 0
```
