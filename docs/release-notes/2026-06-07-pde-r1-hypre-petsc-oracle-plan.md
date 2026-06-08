# Plan: PDE implicit PETSc + hypre oracle (lic#108)

## Summary

Draft vision-aligned plan for tier-2 implicit PDE external oracle: PETSc DM→SNES/KSP→hypre BoomerAMG on `pde_heat_implicit_jacobi`, with GPU PCBJKOKKOS deferred. Opens `sim-pde-research` backlog; no product code in this slice.

## Agent continuation

1. **Read:** [2026-06-07-pde-r1-hypre-petsc-oracle-plan.md](../superpowers/plans/2026-06-07-pde-r1-hypre-petsc-oracle-plan.md), [competitive-pde-engines-plan.md](../benchmarks/competitive-pde-engines-plan.md).
2. **Human:** label lic#108 `plan-approved`, remove `plan-needed`.
3. **Next:** `numerics_researcher` on `cursor/sim-pde-research-loop` after approval.
4. **Blocked on:** Wave A proof gates for pure-Li sparse; distributed mesh (T3).

## Changed

| Path | Evidence |
|------|----------|
| `docs/superpowers/plans/2026-06-07-pde-r1-hypre-petsc-oracle-plan.md` | Canonical plan |
| `docs/benchmarks/competitive-pde-engines-plan.md` | Layer B PDE oracle companion |
| `docs/ecosystem/sim-pde-research-backlog.md` | Research backlog |
| `docs/ecosystem/orchestrator-notes/2026-06-07-orch-pde-r1-hypre-petsc-oracle-plan.md` | Gap mapping |
| `benchmarks/competitive/pde_oracle.toml` | Stub pins |
| `docs/ecosystem/sim-algo-research-grading.md` | `pde` vertical row |
| `docs/benchmarks/competitive-landscape.md` | PETSc/hypre watch note |

## Not changed

- Compiler / stdlib / physics package implementation.
- `pde_external_oracle.py` driver (implement phase).
- `threshold_ratio_cpp` or tier-0 gates.

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A — docs + stub TOML only |
| **Security** | N/A — no FFI in this PR |
| **Performance** | N/A — validity oracle plan only |
| **Downstream** | benchmarks catalog ingest after harness lands |
