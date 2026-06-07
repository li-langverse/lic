# Tier-2 implicit PDE preconditioner rubric (PETSc 3.25 PCBJKOKKOS)

> **Issue:** [#117](https://github.com/li-langverse/lic/issues/117) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-math / G-physics claims), **Easy** (clear oracle vs native path), **Fast** (device-native Jacobi only after proof gates)  
> **Extends:** [#108](https://github.com/li-langverse/lic/issues/108) (hypre BoomerAMG — **AMG deferred there**), [#28](https://github.com/li-langverse/lic/issues/28) (PETSc–Kokkos execution patterns), [#14](https://github.com/li-langverse/lic/issues/14) (physics packages scaffold)  
> **Learned from:** [benchmarks & sims plan](2026-05-14-benchmarks-and-simulations.md), [PH-7e tier-1 honesty](2026-05-30-ph7e-tier1-red-benchmark-honesty.md), [PETSc GPU roadmap](https://petsc.gitlab.io/petsc/release/overview/gpu_roadmap/), [PCBJKOKKOS manual](https://petsc.gitlab.io/petsc/main/manualpages/PC/PCBJKOKKOS/)

## Goal

Define a **preconditioner rubric** for tier-2 implicit PDE benchmark rows so Li can claim parity with exascale PETSc/Kokkos stacks **without** weakening `threshold_ratio_cpp` or shipping unproved solver code. This plan covers **Jacobi-class** preconditioners (`PCJACOBI`, `PCBJKOKKOS`) only; **AMG** (`PCHYPRE` / BoomerAMG) stays in [#108](https://github.com/li-langverse/lic/issues/108).

**North star fit:** Scientific computing / HPC — staged path from shared-C explicit oracles → vendor PETSc implicit oracles → future `li-std-physics-*` native solvers with Lean discharge.

## Non-goals

- Implementing KSP/SNES/DM bindings or Li-native implicit kernels in this plan slice.
- Lowering `threshold_ratio_cpp` or catalog thresholds to green incomplete solvers.
- BoomerAMG / hypre GPU preconditioners (tracked in **#108**).
- Editing `trusted.lean` or adding unproved `unsafe` FFI shortcuts.
- New org repos — physics packages remain in **`lic`** `packages/` until [#14](https://github.com/li-langverse/lic/issues/14) promotion gates pass.

## Dependencies

| Track | ID / issue | Role |
|-------|------------|------|
| Benchmarks harness | **PH-5b** | Tier-2 physics catalog + cross-lang CSV |
| Math / Krylov micro | **PH-2i**, **PH-7e**, **G-math** | Dense LA + `num_gmres` tier-1 baseline before implicit PDE claims |
| Parallel / GPU | **PH-7d**, **PH-7e**, **G-gpu**, **#28** | Kokkos-style execution spaces before device-native PC parity |
| Physics packages | **#14**, **G-physics** | Domain APIs for implicit time integrators |
| Vendor pinning | **#33** | PETSc/Eigen/Kokkos version policy for oracle builds |
| AMG stack | **#108** | hypre BoomerAMG reference — **out of scope here** |

## Preconditioner rubric (acceptance table)

Catalog rows today use **`shared_c_kernel`** with **explicit** time stepping. The rubric below defines the **implicit tier** reference stack when Li adds `-implicit` variants (oracle first, native later).

| Bench id | PDE class | Time discretization (implicit tier) | Linear solve | Reference PC (v1) | PETSc PC type (oracle) | AMG note |
|----------|-----------|-------------------------------------|--------------|-------------------|------------------------|----------|
| `heat_equation_2d` | Parabolic (diffusion) | Backward Euler or Crank–Nicolson | CG on SPD Laplacian | Jacobi (diagonal) | `PCJACOBI` (host) → `PCBJKOKKOS` (device, block size 1) | AMG optional later via **#108** (`PCHYPRE`) |
| `advection_diffusion_2d` | Parabolic + advection | Implicit diffusion, upwind advection (operator-split) or fully implicit | GMRES on nonsymmetric `A` | Jacobi | `PCJACOBI` → `PCBJKOKKOS` | AMG deferred **#108** |
| `wave_equation_2d` | Hyperbolic | **Explicit** (CFL) — no implicit v1 | — | — | — | Implicit variant **not planned** v1 |
| `wave_equation_1d` | Hyperbolic | **Explicit** v1 | — | — | — | Same |
| `fdtd_waveguide_2d` | Hyperbolic (Maxwell) | **Explicit** FDTD v1 | — | — | — | Implicit FDTD out of scope |
| `euler_fluid_2d` | Hyperbolic (compressible) | Explicit or semi-implicit (fractional step) | Pressure Poisson (future) | Jacobi on pressure Laplacian | `PCBJKOKKOS` when Poisson slice lands | AMG for pressure **#108** |
| `combustion_passive` | Advection–reaction | Operator-split implicit diffusion | GMRES + Jacobi | Jacobi | `PCBJKOKKOS` | AMG **#108** |
| `sph_dam_break_2d` | Lagrangian (meshless) | Explicit v1 | — | — | — | Implicit SPH not v1 |
| `schrodinger_1d_barrier` | Schrödinger | Split-operator / Crank–Nicolson (future implicit) | CG on Hermitian stencil | Jacobi | `PCJACOBI` / `PCBJKOKKOS` | — |
| `wind_field_bc` | Elliptic / Poisson | Elliptic solve (future) | CG | Jacobi → AMG | `PCBJKOKKOS` v1; `PCHYPRE` **#108** | Primary AMG consumer |

**Parity claim (minimum):** For rows marked implicit, Li oracle builds must use **PETSc ≥ 3.25** with Kokkos backend and demonstrate **`PCBJKOKKOS`** batched Jacobi on device for the assembled 5-point (or block) stencil matrix. Host `PCJACOBI` is acceptable for correctness-only CI; device path required for perf parity claims.

**Device-native diagonal:** Oracle builds must document whether `MatGetDiagonal` uses `MatGetDiagonal_SeqAIJKOKKOS` (Kokkos path) vs CUDA-only gaps noted in petsc-users Jul 2025 threads (see explorer digest reference in **#117**).

## Oracle vs native Li path

| Stage | Li execution | Preconditioner | Proof gate |
|-------|--------------|----------------|------------|
| **A (today)** | `shared_c_kernel` explicit stencil | None (explicit) | `G-physics` modeling_gap on extern stubs |
| **B (oracle)** | Vendor PETSc/Kokkos C++ driver in `common/*_implicit_petsc.c` | `PCBJKOKKOS` / `PCJACOBI` | Catalog `variant = vendor_petsc_oracle`; correctness hash vs PETSc ref |
| **C (Li FFI)** | Thin proved FFI to pinned PETSc (no reimplementation) | Same PC types | `requires` on matrix symmetry / SPD where applicable |
| **D (native)** | `li-std-physics-pde` implicit step + `li-std-linalg` Krylov | Pure-Li Jacobi diagonal extract | **G-math** + **G-physics** discharge; no `ensures true` on kernels |

**Rule:** Stages **B–C** may land after **`plan-approved`** on this issue; stage **D** requires **`plan-approved`** on [#14](https://github.com/li-langverse/lic/issues/14) plus closed **G-math** slice for Krylov + stencil ops.

## Link to physics packages ([#14](https://github.com/li-langverse/lic/issues/14))

Implicit tier rows map to package scaffolds (stubs today):

| Package | Implicit-tier hooks (planned API) | Benches |
|---------|-----------------------------------|---------|
| `li-std-physics-core` | `ImplicitStep`, `StencilOp`, `BoundaryCondition` traits | all tier-2 PDE |
| `li-std-physics-fluids` | `AdvectionDiffusionSolver`, `PressurePoisson` | `advection_diffusion_2d`, `euler_fluid_2d`, `wind_field_bc` |
| `li-std-physics-heat` (or core) | `HeatDiffusionSolver` | `heat_equation_2d` |
| `li-std-physics-quantum` | `CrankNicolsonSplit` | `schrodinger_1d_barrier` |

Cross-link in `packages/li-std-physics-*/docs/traceability.md` → this plan and **#117** when **#14** plan is approved.

## Sub-phases

| Sub | Deliverable | Repo | Exit gate |
|-----|-------------|------|-----------|
| **A** | This plan + rubric table (issue **#117**) | **lic** | **`plan-approved`** on **#117** |
| **B** | `docs/numerics/tier2-implicit-pde-preconditioner-rubric.md` — normative rubric copy + PETSc version pins (align **#33**) | **lic** | Doc review; links to **#108** AMG deferral |
| **C** | Catalog metadata: `implicit_tier = planned`, `reference_pc = jacobi`, `petsc_pc = PCBJKOKKOS` on `heat_equation_2d`, `advection_diffusion_2d` | **benchmarks** | PR to **benchmarks**; no threshold change |
| **D** | Oracle skeleton: `heat_equation_2d_implicit/` workload with PETSc driver (correctness-only, host `PCJACOBI`) | **benchmarks** + **lic** mirror path | Golden hash vs explicit ref at matched `dt`; **no perf claim** |
| **E** | Device oracle: `PCBJKOKKOS` path + Kokkos backend smoke | **benchmarks** | CI optional `[petsc-kokkos]` tag; pinned PETSc **3.25+** |
| **F** | Physics package trait stubs wired in **#14** slice | **lic** `packages/` | **#14** `plan-approved` |
| **G** | Native Jacobi + GMRES/CG in Li (stage D) | **lic** | **G-math** Krylov closed slice + tier-2 green |

**Agent rule:** Sub-phases **D–G** are **blocked** until sub-phase **A** exit gate (`plan-approved`).

## Tests / benches

| Artifact | Tier | Purpose |
|----------|------|---------|
| `heat_equation_2d` (explicit, current) | 2 | Baseline — unchanged |
| `advection_diffusion_2d` (explicit, current) | 2 | Baseline — unchanged |
| `heat_equation_2d_implicit` (planned) | 2b | Implicit oracle correctness |
| `num_gmres` | 1 | Krylov micro-kernel before implicit PDE perf claims |
| `li-tests/math_linalg/*` | — | SPD / symmetry contracts for CG eligibility |

**Harness policy (benchmarks):**

- New implicit variants get `variant = vendor_petsc_oracle` until native stage **G**.
- `threshold_ratio_cpp` compares against **PETSc oracle**, not explicit shared-C kernel.
- Do **not** weaken explicit-row thresholds when adding implicit rows.

## Provability / gap updates

| Gap | Move | Notes |
|-----|------|-------|
| **G-math** | Partial → Partial+ | Add implicit-tier **planned** bullet; Krylov/stencil proofs remain open |
| **G-physics** | Partial | Link implicit rubric to `physics-*.toml` entries when oracle lands |
| **G-gpu** | Partial | `PCBJKOKKOS` device path depends on **#28** / **PH-7d** execution-space story |
| **G-num** | Stub → Partial (doc) | Implicit PDE stability (CFL, diffusion CFL) as conjecture entries |

Update [provability-gaps.md](../../verification/provability-gaps.md) in sub-phase **B** PR (doc-only).

## REQ mapping

| REQ | Statement |
|-----|-----------|
| **REQ-PDE-PC-1** | Every implicit tier-2 catalog row declares `reference_pc` and `petsc_pc` in rubric table |
| **REQ-PDE-PC-2** | AMG preconditioners reference **#108**; no silent hypre dependency in Jacobi slice |
| **REQ-PDE-PC-3** | Device parity claims require `PCBJKOKKOS` + PETSc ≥ 3.25 + pinned Kokkos version (**#33**) |
| **REQ-PDE-PC-4** | No Li-native implicit solver without **G-math** Krylov closed slice and **#14** package APIs |

## Rollout

1. Merge this plan (**lic** draft PR for **#117**).
2. Human adds label **`plan-approved`**; remove **`plan-needed`** on **#117**.
3. Sub-phase **B** doc PR (**lic**).
4. Sub-phase **C** catalog PR (**benchmarks**).
5. Sub-phases **D–E** oracle PRs (**benchmarks**); coordinate with **#33** pin policy.
6. Track AMG / hypre work only via **#108**.

## Human-only

- [ ] Label **`plan-approved`** on **#117** before any oracle or solver implementation PRs.
- [ ] Confirm PETSc/Kokkos/hypre version pins in **#33** / CI image before device oracle (**E**).
- [ ] Approve **#14** plan before native implicit APIs (sub-phase **F–G**).
- [ ] Merge **#108** plan before any catalog row sets `reference_pc = amg`.

## Vision check (passed)

- **Proof before perf:** Rubric and oracle correctness precede `PCBJKOKKOS` perf claims.
- **No threshold weakening:** Explicit rows unchanged; implicit rows compare to PETSc oracle.
- **No new org repo:** Stays in **lic** + **benchmarks** harness.
- **AMG deferred:** hypre/BoomerAMG explicitly routed to **#108**.
