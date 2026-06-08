# PDE implicit oracle — PETSc + hypre study (`pde-r1-hypre-petsc-oracle-plan`)

**Goal:** `pde_implicit_oracle` · **Issue:** [lic#108](https://github.com/li-langverse/lic/issues/108)  
**Agent:** `code_implementer` · **Mode:** study-only (validity locked; no perf claims)  
**North star:** PH-5b, PH-7e, PH-7d; G-math sparse LA; G-physics tier-2 honesty  
**Plan:** [2026-06-07-pde-r1-hypre-petsc-oracle-plan.md](../../superpowers/plans/2026-06-07-pde-r1-hypre-petsc-oracle-plan.md)

---

## Problem

Tier-2 `pde_heat_implicit_jacobi` proves Jacobi inner iterations on 64×64 via shared-C kernel. PETSc+hypre stacks provide SNES/KSP + BoomerAMG for production implicit PDE — Li has no external validity column yet.

| Signal | State (2026-06-08) |
|--------|---------------------|
| T0 Jacobi kernel | WP3 `gen_wp3_tier2_harnesses.py` |
| Li smoke | `sim_scientific_oracle_checksum_heat()` explicit 1D stencil |
| External oracle | `pde_external_oracle.py` stub → `stub_ok` manifest |
| GPU PC | `PCBJKOKKOS` deferred (lic#28, G-gpu) |

---

## Reference stack (CPU T2)

```
DMCreate → DMDA (2D) → SNES + KSP → PCHYPRE boomeramg → SNESSolve
```

Pinned: PETSc **3.25.x**, hypre **2.32.x** — see `benchmarks/tier2_physics/pde_oracle_external/PINNED.md`.

---

## Size scaling (survey targets)

| nx×ny | steps | Inner solve | Li action |
|-------|-------|-------------|-----------|
| 32×32 | 3_000 | Jacobi 6 / hypre AMG | Study tolerance table |
| 64×64 | 12_000 | Jacobi 6 (T0 default) | Stub manifest + API sketch |
| 128×128 | 3_000 | hypre AMG | Deferred until T2 driver |

**Tolerance advisory:** L2 vs T0 checksum ±1e-3 at 64×64 until real PETSc driver lands.

---

## Grade matrix

| Gate | Result | Evidence |
|------|--------|----------|
| Validity (stub) | pass | `pde_external_oracle_stub.sh` exit 0 |
| Registry | pass | `check-hpc-competitive.sh` + `pde_oracle.toml` |
| API sketch | pass | `apply_heat_laplacian_1d`, `pde_implicit_jacobi_micro_checksum` |
| Perf | skip | No PETSc wall-time row |
| Memory | skip | Study-only |
| Security | skip | No native FFI |

---

## Repro

```bash
cd lic
./scripts/check-hpc-competitive.sh
./li-tests/tooling/pde_external_oracle_stub.sh
SIM_RESEARCH_VERTICAL=pde SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-08-pde-r1-hypre-petsc-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh
```
