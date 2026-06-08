# Competitive PDE engines plan (implicit PETSc + hypre oracles)

**Status:** Draft (rev. 0 — 2026-06-07)  
**Audience:** Benchmark maintainers, sim-pde-research agents  
**Related:** [competitive-landscape.md](competitive-landscape.md) · `benchmarks/competitive/pde_oracle.toml` · [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md)  
**Issue:** [lic#108](https://github.com/li-langverse/lic/issues/108) · **PH:** PH-5b, PH-7e, PH-7d · **G:** G-math, G-physics

Layer A in the HPC registry tracks **language runtimes** (cpp, rust, julia, li). This plan adds **Layer B domain solvers** — PETSc + hypre — as **external oracle** columns for tier-2 `pde_heat_implicit_jacobi`, without claiming production CFD/FEA parity.

---

## 1. Goal

| Today | Target (pde-r1 slice) |
|-------|------------------------|
| cpp/rust/julia share Jacobi C kernel; Li has explicit heat oracle | Same + **`petsc_hypre`** CSV `lang` row for **validity** (L2 / checksum), optional **perf** later |
| `verticals.toml` `pde_heat_2d` stub | `oracle = external_binary` when driver lands |
| No pinned PETSc/hypre version | Pinned releases in `pde_oracle.toml` (align [#33](https://github.com/li-langverse/lic/issues/33)) |
| Explorer marks petsc/hypre `missing` | Watch → active rows in `registry.toml` |

**Not in scope (this slice):** OpenFOAM cavity oracle; distributed DM; full GPU strong scaling; pure-Li AMG.

---

## 2. Workload contract (`pde_heat_implicit_jacobi`)

Canonical parameters (WP3 harness / `gen_wp3_tier2_harnesses.py`):

| Field | Value | Notes |
|-------|-------|-------|
| nx, ny | 64 | Square grid |
| steps | 12_000 | Outer time steps |
| jacobi_iters | 6 | Inner linear iterations per step (T0 reference) |
| alpha | 0.25 | Diffusivity |
| dx | 0.02 | Grid spacing |
| dt | 0.001 | Backward Euler |
| IC | sin(0.2·i)·sin(0.2·j) | Separable sine |
| BC | Dirichlet zero on boundary | 5-point stencil |
| discretization | Backward Euler + inner Jacobi | T0; oracle uses SNES/KSP + hypre |

**Li micro oracle (in-repo today):** `sim_scientific_oracle_checksum_heat()` — explicit 1D Laplacian stencil smoke (distinct from implicit Jacobi kernel; both under `vertical_pde_heat_2d()`).

**External oracle metric (planned):** final field checksum + L2 error vs analytical sin solution at t=T; tolerance advisory ±1e-3 vs T0 at 64×64 until real drivers land.

---

## 3. Reference stack (PETSc + hypre)

Target build for T2 CPU oracle (document pins in `PINNED.md` at implement phase):

```
DMCreate → DMDA (2D) → DMSetUp
  → SNESCreate → SNESSetDM
  → KSPCreate → KSPSetDM
  → PCSetType(PC, PCHYPRE) → PCHYPRESetType(PC, "boomeramg")
  → SNESSolve (backward Euler residual per step)
```

| Option | Value | Notes |
|--------|-------|-------|
| `-pc_type` | `hypre` | hypre preconditioner |
| `-pc_hypre_type` | `boomeramg` | Algebraic multigrid |
| `-ksp_type` | `gmres` or `cg` | SPD heat → cg preferred when proved |
| `-snes_type` | `newtonls` or `ksponly` | Linear heat: ksponly acceptable |

**T2b GPU slice (deferred):** PETSc 3.25 `PCBJKOKKOS` batched preconditioner — requires [#28](https://github.com/li-langverse/lic/issues/28) Kokkos execution policy alignment and human approval for **G-gpu** slice.

---

## 4. CSV columns (future `latest.csv`)

| `lang` | `kernel_honesty` | Row type | Driver |
|--------|------------------|----------|--------|
| `cpp` | `reference_native` | perf + validity | WP3 Jacobi kernel |
| `rust` / `julia` | `shared_c_kernel` | perf | same binary as cpp |
| `li` | `pure_li` / `modeling_gap` | validity first | `li/main.li` or vendor hook |
| **`petsc_hypre`** | **`external_binary`** | **validity first** | `pde_external_oracle.py` |

Perf wall-time comparison to PETSc+hypre is **out of scope** until workloads are provably equivalent (same IC, same dt, same linear tolerance).

---

## 5. Registry files

| File | Role |
|------|------|
| `benchmarks/competitive/registry.toml` | `petsc_hypre_heat_implicit` on **watch** → **active** |
| `benchmarks/competitive/pde_oracle.toml` | Oracle pins, drivers, `workload_class`, status (`stub` → `active`) |
| `benchmarks/harness/pde_external_oracle.py` | Stub driver + manifest writer (implement phase) |

Validate (after implement):

```bash
./scripts/check-hpc-competitive.sh
./li-tests/tooling/pde_external_oracle_stub.sh
```

---

## 6. Numerics pin policy (cross-link #33)

Oracle builds must cite the same numerics discipline as Eigen/BLAS tier-1 policy ([#33](https://github.com/li-langverse/lic/issues/33)):

| Dependency | Pin strategy |
|------------|--------------|
| PETSc | Exact release tag (e.g. 3.25.x) in `pde_oracle.toml` |
| hypre | Bundled with PETSc or standalone 2.32.x — document ABI |
| MPI | OpenMPI 4.x or MPICH — single-rank default for T2 |
| Kokkos | Only for T2b; match PETSc configure `--with-kokkos` |

No floating distro packages in CI truth tables.

---

## 7. Stub driver (v0 — implement phase)

`benchmarks/harness/pde_external_oracle.py`:

- `--engine petsc_hypre --dry-run` writes stub `li_sim_summary_v1` JSON
- `--grid 64` selects WP3 default
- Skips gracefully when `PETSC_DIR` unset (CI default)

Gate script: `li-tests/tooling/pde_external_oracle_stub.sh` (implement phase).
