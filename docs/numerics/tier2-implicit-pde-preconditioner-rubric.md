# Tier-2 implicit PDE preconditioner rubric

**Status:** Normative (sub-phase **B**, [lic#117](https://github.com/li-langverse/lic/issues/117))  
**Audience:** Benchmark maintainers, physics package authors, numerics agents  
**Plan:** [2026-06-07-tier2-implicit-pde-pc-rubric-petsc325-pcbjkokkos.md](../superpowers/plans/2026-06-07-tier2-implicit-pde-pc-rubric-petsc325-pcbjkokkos.md)  
**Related:** [lic#108](https://github.com/li-langverse/lic/issues/108) (AMG/hypre), [lic#14](https://github.com/li-langverse/lic/issues/14) (physics packages), [lic#28](https://github.com/li-langverse/lic/issues/28) (Kokkos execution), [lic#33](https://github.com/li-langverse/lic/issues/33) (vendor pins)  
**PH / G:** PH-5b, PH-2i, PH-7e, PH-7d · G-math, G-physics, G-gpu, G-num

This document is the **normative rubric** for tier-2 implicit PDE benchmark rows. It defines solver class, reference preconditioner, and PETSc PC type mapping. **No solver or oracle implementation** is authorized by this doc alone — see rollout gates below.

---

## Scope

| In scope | Out of scope |
|----------|--------------|
| Jacobi-class PCs: `PCJACOBI`, `PCBJKOKKOS` | BoomerAMG / `PCHYPRE` → **[#108](https://github.com/li-langverse/lic/issues/108)** |
| Rubric table for tier-2 catalog ids | OpenFOAM / full CFD oracle columns |
| Staged oracle → native path | Li-native implicit kernels before **G-math** Krylov slice |
| Physics package scaffold links (**#14**) | `trusted.lean` or unproved FFI |

**North star fit:** Scientific computing / HPC — proof-before-perf; explicit shared-C rows stay unchanged until implicit variants land with separate oracle thresholds.

---

## Preconditioner rubric table

Today’s tier-2 PDE harnesses use **`shared_c_kernel`** with **explicit** time stepping. The table defines the **implicit tier** reference when `-implicit` variants are added.

| Bench id | Solver class | Time discretization (implicit tier) | Reference PC | PETSc PC type (oracle) | AMG |
|----------|--------------|-------------------------------------|--------------|------------------------|-----|
| `heat_equation_2d` | Parabolic diffusion | Backward Euler or Crank–Nicolson | Jacobi | `PCJACOBI` → `PCBJKOKKOS` | Optional via **#108** |
| `advection_diffusion_2d` | Parabolic + advection | Implicit diffusion + upwind advection | Jacobi | `PCJACOBI` → `PCBJKOKKOS` | **#108** |
| `wave_equation_2d` | Hyperbolic | Explicit v1 only | — | — | — |
| `wave_equation_1d` | Hyperbolic | Explicit v1 only | — | — | — |
| `fdtd_waveguide_2d` | Hyperbolic (Maxwell) | Explicit FDTD v1 | — | — | — |
| `euler_fluid_2d` | Compressible flow | Semi-implicit; pressure Poisson (future) | Jacobi (pressure Laplacian) | `PCBJKOKKOS` when Poisson lands | **#108** |
| `combustion_passive` | Advection–reaction | Operator-split implicit diffusion | Jacobi | `PCBJKOKKOS` | **#108** |
| `sph_dam_break_2d` | Lagrangian meshless | Explicit v1 | — | — | — |
| `schrodinger_1d_barrier` | Schrödinger | Crank–Nicolson / split-operator (future) | Jacobi | `PCJACOBI` / `PCBJKOKKOS` | — |
| `wind_field_bc` | Elliptic Poisson | Elliptic solve (future) | Jacobi → AMG | `PCBJKOKKOS` v1; `PCHYPRE` **#108** | Primary AMG row |

**REQ-PDE-PC-1:** Every implicit tier-2 row above declares `reference_pc` and `petsc_pc` before catalog metadata (**sub-phase C**, benchmarks repo).

---

## PETSc / Kokkos parity minimum

| Claim | Requirement |
|-------|-------------|
| Correctness-only (host CI) | PETSc `PCJACOBI` on assembled 5-point stencil |
| Device-native Jacobi parity | PETSc **≥ 3.25**, Kokkos backend, **`PCBJKOKKOS`** (block size 1 for scalar Jacobi) |
| Diagonal extraction | Document `MatGetDiagonal_SeqAIJKOKKOS` vs host fallback ([PCBJKOKKOS manual](https://petsc.gitlab.io/petsc/main/manualpages/PC/PCBJKOKKOS/)) |
| Version pins | Align [lic#33](https://github.com/li-langverse/lic/issues/33) before oracle CI images |

**REQ-PDE-PC-3:** Perf parity claims on implicit rows require all device rows in the table above.

---

## Oracle vs native execution path

| Stage | Li surface | Preconditioner | Gate |
|-------|------------|----------------|------|
| **A (today)** | `shared_c_kernel` explicit stencil | None | Tier-2 explicit verify unchanged |
| **B** | Vendor PETSc driver (`*_implicit_petsc.c`) | `PCJACOBI` / `PCBJKOKKOS` | `variant = vendor_petsc_oracle`; hash vs PETSc ref |
| **C** | Thin proved FFI to pinned PETSc | Same PC types | SPD / symmetry `requires` where applicable |
| **D** | `li-std-physics-*` + `li-std-linalg` Krylov | Pure-Li Jacobi diagonal | **G-math** + **G-physics** discharge |

**REQ-PDE-PC-4:** Stage **D** blocked until **#14** plan-approved and **G-math** Krylov closed slice (`num_gmres` tier-1 baseline).

**Harness policy:** Implicit variants compare `threshold_ratio_cpp` against the **PETSc oracle**, not the explicit shared-C kernel. Do **not** weaken explicit-row thresholds.

---

## Physics packages ([#14](https://github.com/li-langverse/lic/issues/14))

Implicit tier APIs are scaffold-only until **#14** promotion. Package traceability links:

| Package | Planned implicit API | Benches |
|---------|---------------------|---------|
| [`li-std-physics-core`](../../packages/li-physics-core/docs/traceability.md) | `ImplicitStep`, `StencilOp`, `BoundaryCondition` | All tier-2 PDE |
| [`li-std-physics-fluids`](../../packages/li-physics-fluids/docs/traceability.md) | `AdvectionDiffusionSolver`, `PressurePoisson` | `advection_diffusion_2d`, `euler_fluid_2d`, `wind_field_bc` |
| [`li-std-physics-core`](../../packages/li-physics-core/docs/traceability.md) | `HeatDiffusionSolver` (core until heat package splits) | `heat_equation_2d` |
| [`li-std-physics-quantum`](../../packages/li-physics-quantum/docs/traceability.md) | `CrankNicolsonSplit` | `schrodinger_1d_barrier` |

---

## Requirements summary

| REQ | Statement |
|-----|-----------|
| **REQ-PDE-PC-1** | Implicit tier-2 rows declare `reference_pc` + `petsc_pc` in rubric / catalog |
| **REQ-PDE-PC-2** | AMG references **#108** only; no silent hypre in Jacobi slice |
| **REQ-PDE-PC-3** | Device claims need `PCBJKOKKOS` + PETSc ≥ 3.25 + pinned Kokkos (**#33**) |
| **REQ-PDE-PC-4** | No native implicit solver without **G-math** Krylov + **#14** APIs |

---

## Rollout (remaining)

| Sub | Deliverable | Repo | Status |
|-----|-------------|------|--------|
| A | Plan + table | **lic** | Done ([plan](../superpowers/plans/2026-06-07-tier2-implicit-pde-pc-rubric-petsc325-pcbjkokkos.md), **plan-approved**) |
| **B** | This normative doc + provability-gaps | **lic** | **This PR** |
| C | Catalog metadata (`implicit_tier`, `reference_pc`, `petsc_pc`) | **benchmarks** | Pending |
| D–G | Oracle drivers, device smoke, native solvers | **benchmarks** + **lic** | Blocked on C + **#33** / **#14** |

---

## External references

- [PETSc GPU roadmap](https://petsc.gitlab.io/petsc/release/overview/gpu_roadmap/)
- [PCBJKOKKOS](https://petsc.gitlab.io/petsc/main/manualpages/PC/PCBJKOKKOS/)
- [benchmarks.md](../benchmarks.md) — tier-2 harness policy
