# Numerics integrator backlog (agent todos)

**Status:** Active  
**Issue:** [lic#35](https://github.com/li-langverse/lic/issues/35)  
**Plan:** `docs/superpowers/plans/2026-06-07-sundials-stiff-ode-sensitivity-plan.md`  
**Package:** `li-math-numerics`  
**Registry:** `benchmarks/competitive/ode_oracle.toml` (proposed)

---

todos:
- id: gap-ode-r0-plan-doc
  content: "ode: canonical SUNDIALS-class stiff ODE plan (lic#35)"
  status: completed
  gap_orchestrator: true
- id: ode-r1-gap-matrix
  content: "Document Li vs SUNDIALS feature matrix; propose tier-2 stiff catalog rows"
  status: pending
- id: ode-r2-oracle-harness
  content: "CVODE external oracle harness + competitive gate (Robertson, Van der Pol)"
  status: pending
- id: ode-r3-bdf-stub
  content: "li-math-numerics BDF-1/2 fixed-step stubs with contracts"
  status: pending
- id: ode-r4-newton-implicit
  content: "Newton wrapper for implicit BDF step; cg_iteration linkage"
  status: pending
- id: ode-r5-adaptive
  content: "Adaptive step + embedded error estimate (deferred — human gate)"
  status: deferred
- id: ode-r6-sensitivity
  content: "Forward/adjoint sensitivity column (CVODES class; deferred)"
  status: deferred

---

## Agent instructions

- One todo per loop iteration (`numerics-integrator-loop` — to be wired post `plan-approved`).
- After each slice: `bash scripts/ph-sci-ode-oracle-competitive-gates.sh` when oracle paths exist.
- Update `docs/verification/provability-gaps.md` G-math/G-num slices when BDF stubs land.
- Catalog-only changes require **benchmarks** PR + [benchmarks#179](https://github.com/li-langverse/benchmarks/issues/179) path honesty.

## Current baseline (2026-06-07)

| Integrator | `li-math-numerics` | Tier-1 catalog | SUNDIALS analog |
|------------|-------------------|----------------|-----------------|
| Semi-implicit Euler | `euler_step_vec2` | `num_integ_euler` | Euler (nonstiff) |
| Velocity Verlet | `verlet_step_vec2` | `num_integ_verlet` | Symplectic |
| RK4 scaffold | `rk4_step_4` | `num_integ_rk4` | ERK (partial) |
| CG iteration | `cg_iteration` | — | KINSOL precursor |
| BDF stiff | **missing** | **missing** | CVODE BDF |
| Adaptive | **missing** | **missing** | CVODE error control |
| Sensitivity | **missing** | **missing** | CVODES |
