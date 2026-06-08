# Physics packages — scaffold `lib.li` → domain APIs (tier-2 aligned)

> **Issue:** [#14](https://github.com/li-langverse/lic/issues/14) · **Related:** [#50](https://github.com/li-langverse/lic/issues/50) (org mirrors only) · **Blocked by (informal):** `feat/physics-module-packages` merge per [PUSH_PR.md](../../physics/PUSH_PR.md)  
> **Vision:** **Provable** (typed units + contract-linked integrators), **Easy** (`import physics.*` composable surface), **Fast** (pure-Li kernels only after proof — PH-7e)  
> **north_star_fit:** Scientific computing + tier-2 game physics · **PH-5b**, **PH-2i**, **PH-7e** · **G-physics**, **G-math**  
> **Learned from:** [benchmarks-and-simulations](2026-05-14-benchmarks-and-simulations.md), [GAME_DEV.md](../../physics/GAME_DEV.md), [numerical-policy.md](../../physics/numerical-policy.md), [org mirrors plan](2026-06-07-li-physics-org-mirrors-plan.md) (scope boundary)

## Goal

Expand the **12 `li-physics-*` workspace packages** from scaffold / toy kernels into **real domain surfaces** that tier-2 benchmarks and game engines can import:

1. **Units & constants** — typed SI helpers and domain constants in `physics.core`
2. **Fields** — grid / SoA field types with shape contracts (not raw `array[8, float]` forever)
3. **Integrator hooks** — profile-driven selection wired to `math.numerics` + `PhysicsProfile` (compile-time table v1; decorator PHY-n deferred)
4. **Bench alignment** — each subdomain exports APIs referenced by at least one **tier-2** harness row or composable smoke
5. **Pure-Li path** — document and land reference kernels per [GAME_DEV.md](../../physics/GAME_DEV.md) (`three_body_pure`, MD force loops) before claiming perf parity

**Separate track:** org mirror publish remains [#50](https://github.com/li-langverse/lic/issues/50) / [mirrors plan](2026-06-07-li-physics-org-mirrors-plan.md). Domain depth here does **not** require mirror push first, but mirrors should not advertise APIs that fail smoke until this plan’s Wave C gates pass.

## Non-goals

- Production **PETSc KSP/SNES/DM** or **Kokkos Views** stacks in package `lib.li` (tracked in explorer issues [#117](https://github.com/li-langverse/lic/issues/117), [#108](https://github.com/li-langverse/lic/issues/108), [#110](https://github.com/li-langverse/lic/issues/110)) — tier-2 v1 stays **`shared_c_kernel` oracle + Li wrapper** with honest `modeling_gap`
- Weakening `threshold_ratio_cpp` or catalog thresholds to green incomplete APIs
- Renaming org repos or mirror push (lic#50)
- `@physics(tier=…)` decorator elaboration before PHY-n language phase lands ([numerical-policy.md](../../physics/numerical-policy.md))
- Editing `trusted.lean` (human-approved issues only)
- Adding GitHub Actions `schedule:` cron

## Current state (2026-06-08 audit)

| Package | `src/lib.li` lines | Scaffold signal | Tier-2 / composable anchor |
|---------|-------------------:|-----------------|---------------------------|
| `li-physics-core` | 182 | Profiles present; **no unit types** | All benches via `PhysicsProfile` |
| `li-physics-runtime` | 187 | Single-body world; scene sync stubs | `rigid_body_stack`, composable `import_physics_runtime` |
| `li-physics-particles` | 405 | Rich MD/LJ; some `ensures result == 0` stubs | `nbody_gravity`, `md_lennard_jones` |
| `li-physics-rigid` | 88 | PGS stub | `rigid_body_stack`, `ragdoll_chain` |
| `li-physics-fluids` | 83 | 8-cell toy grids | `euler_fluid_2d`, `sph_dam_break_2d`, `cloth_swing` |
| `li-physics-quantum` | 90 | 1D TDSE helpers | `qm_*` smokes, `quantum_tddft_*` |
| `li-physics-em` | 72 | Jacobi smoke | `fdtd_*`, Poisson tier-2 |
| `li-physics-weather` | 59 | Diffusion stub | `wind_field_bc`, advection benches |
| `li-physics-aero` | 62 | Exponential atmosphere | orbit / aero catalog rows |
| `li-physics-chem` | 42 | Combustion stub | `combustion_passive` |
| `li-physics-relativity` | 53 | Schwarzschild factor stub | weak-field GR smokes |
| `li-physics-hep` | 27 | **Placeholder** MC (`ensures result == 0.0`) | education-tier only |

**plan-completion-audit** flags packages **&lt;80 lines** (hep, chem, relativity, weather, aero, em) plus **extern-heavy** wrappers without proof-database linkage.

**Naming debt:** README/PUBLISH still cite legacy `li-std-physics-*` — align in Wave A (same script as lic#50).

## Architecture

```text
physics.core          units, constants, PhysicsProfile, FieldGrid types
    │
    ├── physics.runtime   PhysicsWorld, integrator schedule, scene hooks
    ├── physics.rigid     bodies, constraints, PGS step hooks
    ├── physics.particles SoA, force kernels, MD integrator hooks
    ├── physics.fluids    grid + SPH field ops, cloth PBD
    ├── physics.weather   advection / diffusion on fields
    ├── physics.aero      atmosphere + orbital helpers
    ├── physics.chem      reaction rates, passive combustion
    ├── physics.em        Coulomb, Poisson, FDTD stencils
    ├── physics.quantum   TDSE 1D, normalization, split-operator hooks
    ├── physics.relativity SR / weak-field metrics
    └── physics.hep       toy MC (education tier — explicit non-SOTA)

math.numerics         Verlet, RK4, symplectic selectors (integrator impl)
benchmarks/tier2_*    shared_c_kernel oracle + correctness gate
```

**Proof order:** package `requires`/`ensures` on **Li-visible** APIs first; extern C kernels remain **`modeling_gap`** until P-physics lemmas cite bench golden values ([proof-database/entries/physics-*.toml](../../verification/proof-database/entries/physics-mechanics.toml)).

## Dependencies

| Dependency | Why |
|------------|-----|
| **PH-2i** / `li-math`, `li-math-numerics` | Vec types, dot, integrator primitives |
| **PH-5b** | Tier-2 harness correctness gates |
| **PH-7e** | Pure-Li reference kernels (`three_body_pure`) after proof |
| **PH-2j** | `var` object write-back for composable smokes |
| **lic#50** mirrors (optional ordering) | Publish after package smokes green |
| **benchmarks** catalog | Row `package_refs` updated when API stabilizes |
| **PUSH_PR.md** branch | Ensure monorepo packages on `main` match published intent |

## REQ / PKG traceability

| REQ id | Requirement |
|--------|-------------|
| **REQ-PHYS-UNITS-01** | `physics.core` exports typed unit helpers + SI constants with `requires` positivity |
| **REQ-PHYS-FIELD-01** | Subdomain packages use named field types (not anonymous fixed-8 arrays in public API) |
| **REQ-PHYS-INT-01** | `select_integrator_order` + `math.numerics` hook documented per tier table ([numerical-policy.md](../../physics/numerical-policy.md)) |
| **REQ-PHYS-BENCH-01** | Each package `PUBLISH.md` lists ≥1 tier-2 or composable bench id |
| **REQ-PHYS-PROOF-01** | New lemmas registered in `docs/verification/proof-database/entries/physics-*.toml` before `ensures` claims on force/energy |

Each package keeps `pkg_id = PKG-li-physics-*` in `li.toml`; update stale `PKG-li-std-*` in PUBLISH headers in Wave A.

## Sub-phases

| Wave | Deliverable | Exit gate |
|------|-------------|-----------|
| **A — Foundation** | `physics.core`: `SiUnit` tags, `PhysicalConstant` table, `ScalarField2D` / `VectorField2D` skeleton; fix `li-std-*` PUBLISH metadata | `lic check` + smoke; `plan-completion-audit` no stale PKG ids |
| **B — Integrator spine** | Wire `select_integrator_order` → `math.numerics` selectors; `physics.runtime` calls numerics hook in `physics_step` | Composable `import_physics_runtime` runs multi-substep with logged tier |
| **C — Thin domains (5)** | Expand **hep, chem, relativity, weather, aero** to ≥120 lines meaningful API each | Package smoke + 1 bench param fixture each; no `ensures result == 0.0` placeholders |
| **D — Fluids / rigid / em** | Grid sizes from bench `params.toml`; PGS / Jacobi / FDTD stencils as typed field ops | Tier-2 smokes `euler_fluid_2d`, `rigid_body_stack`, `fdtd_*` import package APIs |
| **E — Particles / quantum depth** | Replace stub `nbody_pair_force`; TDSE split-operator step hook | `md_lennard_jones`, `nbody_gravity`, `qm_*` harness imports package surface |
| **F — Pure-Li reference (PH-7e)** | Land `three_body_pure` path in Li per GAME_DEV; document C oracle deprecation timeline | Bench green under correctness gate; **no threshold weakening** |
| **G — Proof + composable** | Extend `import_physics_*` composable tests; update proof-database rows | **G-physics** evidence cited; explorer scaffold-only signal cleared |

Implementation PRs should be **one subdomain per PR** after Wave A–B land (keeps review + CI scoped).

## Package → bench mapping (normative v1)

| Package | Public API additions (v1) | Bench / smoke ids |
|---------|---------------------------|-------------------|
| `physics.core` | `unit_seconds`, `unit_meters`, `c_light`, `k_boltzmann`, field types | all tier-2 via profile |
| `physics.runtime` | multi-body slot table stub, integrator dispatch | `rigid_body_stack`, composable runtime |
| `physics.rigid` | `RigidBodyState`, `contact_manifold`, `pgs_step` | `rigid_body_stack`, `ragdoll_chain` |
| `physics.particles` | SoA `ParticleBlock`, `lj_force`, `verlet_hook` | `md_lennard_jones`, `nbody_gravity` |
| `physics.fluids` | `FluidGrid2D`, `euler_step`, `sph_density` | `euler_fluid_2d`, `sph_dam_break_2d`, `cloth_swing` |
| `physics.weather` | `WindField`, `advect_scalar`, `diffuse_step` | `wind_field_bc` |
| `physics.aero` | `AtmosphereModel`, `orbit_energy` | aero catalog rows |
| `physics.chem` | `ArrheniusRate`, `combustion_step` | `combustion_passive` |
| `physics.em` | `PoissonJacobi`, `fdtd_hx_hy` | `fdtd_*`, Poisson tier-2 |
| `physics.quantum` | `Wavefunction1D`, `split_operator_step` | `qm_*`, TDDFT smokes |
| `physics.relativity` | `schwarzschild_factor`, `lorentz_gamma` | weak-field smokes |
| `physics.hep` | `DecayChannel`, `isotropic_sample` (toy, documented) | education tier only |

## Tests / benches

| Gate | Where |
|------|-------|
| `lic check packages/li-physics-*/src/lib.li` | Monorepo + mirror CI |
| `lic build packages/li-physics-*/li-tests/smoke/builds.li` | Per package |
| `li-tests/composable/import_physics_*.li` | Extend to all 12 imports (currently 2) |
| Tier-2 correctness | `benchmarks/harness/bench.py` — energy drift / golden hash before timing |
| Pure-Li path | `three_body_pure`, `md_lennard_jones` Li reference impl |
| Proof database | `./scripts/check-proof-database.sh` after new `physics-*.toml` rows |

**Explicit deferral:** implicit PDE with PETSc preconditioners — use shared C oracle until [lic#117](https://github.com/li-langverse/lic/issues/117) **`plan-approved`** implementation lands; do **not** fake KSP in stub APIs.

## Provability / gap register

| Gap | Move | Notes |
|-----|------|-------|
| **G-physics** | Partial → Partial+ | Add lemmas for unit positivity + integrator order; link bench golden refs |
| **G-math** | Partial (cross-link) | Field dot products use PH-2i surface |
| **G-lean** | Unchanged | No trusted.lean edits |
| **modeling_gap** on extern | Document | `extern proc li_rt_*` and `shared_c_kernel` wrappers labeled in PUBLISH |

No gap moves to **Done** from documentation-only PRs.

## Rollout

1. Human labels **`plan-approved`** on #14.
2. Merge any pending **`feat/physics-module-packages`** / PUSH_PR work so `main` matches package tree.
3. **lic** Wave A–B PR (core + runtime integrator spine).
4. **lic** Wave C–E PRs (one subdomain at a time); each updates package `PUBLISH.md` + proof-database stub row.
5. **lic** Wave F pure-Li PR (PH-7e gated).
6. **benchmarks** PR: catalog `package_refs` + dashboard notes (ecosystem-first).
7. Optional: trigger lic#50 mirror push after Wave C smokes green.
8. Close #14 when explorer + `plan-completion-audit` report no scaffold-only physics packages and composable matrix covers all 12 imports.

## Human-only

- [ ] Label **`plan-approved`** on #14 before implementation agents run.
- [ ] Approve **`feat/physics-module-packages`** merge if branch still unpublished ([PUSH_PR.md](../../physics/PUSH_PR.md)).
- [ ] Remove **`plan-needed`** after plan PR merge.
- [ ] Review pure-Li vs C-oracle deprecation for tier-2 flagship benches (Wave F).
- [ ] Merge **benchmarks** catalog PR (agents prepare; human review).

## Deferred (explicit)

- PETSc/Kokkos production implicit stacks (lic#117, #108, #110)
- `@physics(tier=…)` compile-time decorator (PHY-n language phase)
- lip registry `publish` (phase 8d) until coverage ≥80% per package
- HPX async scheduling overlap (lic#112) — orthogonal to domain API surface
- Org mirror creation (lic#50)
