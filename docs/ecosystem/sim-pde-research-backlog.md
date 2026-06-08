# PDE simulation algorithm research backlog

**Status:** Active (opened by pde-r1 plan — lic#108)  
**Vertical:** `pde`  
**Registry:** `benchmarks/competitive/algo_registry.json` (family `pde`, ids 201–220)  
**Plan:** [2026-06-07-pde-r1-hypre-petsc-oracle-plan.md](../superpowers/plans/2026-06-07-pde-r1-hypre-petsc-oracle-plan.md)

---

todos:
- id: pde-r0-sota-survey
  content: "PETSc SNES/KSP + hypre BoomerAMG + PCBJKOKKOS — map to algo_registry 201–220 and tier-2 rows"
  status: pending
  study_only: true

- id: pde-r1-hypre-petsc-oracle-plan
  content: "PETSc+hypre external oracle column for pde_heat_implicit_jacobi — plan doc + gate contract"
  status: completed
  study_only: true
  handoff_implement: sim-pde-r1-oracle-harness

---

## Agent instructions

1. Branch: `cursor/sim-pde-research-loop` (create on first implement slice after **plan-approved**).
2. Run: `SIM_RESEARCH_VERTICAL=pde ./scripts/sim-algo-research-gates.sh`
3. Grading: [sim-algo-research-grading.md](sim-algo-research-grading.md) — validity locked.
4. Do not weaken `threshold_ratio_cpp` or tier-0 stability rows.
