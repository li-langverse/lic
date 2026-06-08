---
workflow_repo: lic
branch: main
plan: data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md
---

# PH-SCI simulation gap-close plan

**Last updated:** 2026-06-06 · **main @** `e87165b7` (PH-SCI-GPU-16..19 via #847; HEAD may be newer)
**Progress:** **19 / 33 WPs done (~58%)** — Phase 0 + Phase 1 **complete on `main`**
**Scope:** All `li-sim-*` packages, simulation-coupled `li-physics-*`, `li-scene`, `li-math-numerics`, `li-sim-scientific`, and `science_gpu` / `@gpu` placement coverage.
**Honesty:** `lic check` / empty `builds.li` smokes ≠ product parity. See [studio-full-implementation-plan.md](../../docs/game-dev/studio-full-implementation-plan.md) §1 honesty rule.

## GPU Chem / DFT + Electrochemistry (merged — #847 on `main`)

See **[ph-sci-gpu-chem-dft.md](ph-sci-gpu-chem-dft.md)** for WP-SCI-GPU-CHEM-01..04, stub vs real audit, and PH-ML Phase 3 LKIR hooks. Electrochemistry WP-ECHEM-01..08 and PH-SCI-GPU-16..19 gates landed on **`main`** via PR #847 (`e87165b7`) — see [ph-sci-electrochemistry-sim-plan.md](ph-sci-electrochemistry-sim-plan.md). The `science_gpu` suite now includes **20** manifest rows (GPU-01..15 + GPU-16..19).

## Iteration rules

1. **Phase 0 + Phase 1 are done** — do not reopen unless a regression fails `scripts/ph-sci-phase0-gates.sh`.
2. Work **Phase 2 next** ([ph-sci-gap-close-phase2.md](ph-sci-gap-close-phase2.md)), then Phase 3 vendor GPU.
3. One WP or logical chunk per iteration; commit + push to a feature branch off `main`.
4. Verify with WSL `./build-wsl/compiler/lic/lic build …` and `./li-tests/run_all.sh science_gpu` before ending an iteration.
5. Phase 2+ gates TBD; Phase 0 gate remains the regression spine.

## Completion gate

```bash
bash scripts/ph-sci-phase0-gates.sh
```

## K8s handoff

**Phase 2 worker** (current — does not auto-scale; run setup when ready):

```bash
cd li-cursor-agents
export KUBECONFIG=~/.kube/config-homelab
export GH_TOKEN=... CURSOR_API_KEY=...
bash scripts/setup-engine-k8s-ph-sci-gap-close-phase2.sh
kubectl -n li-swarm logs -f deploy/li-ph-sci-gap-close-phase2
```

Legacy Phase 0 worker (`li-ph-sci-simulation-gap-close`) is superseded; keep scaled to 0 unless replaying history.

## Cross-references

| Doc | Relevance |
|-----|-----------|
| [PH-world-studio-program.md](../../docs/game-dev/PH-world-studio-program.md) | PH-SIM, PH-SCI, PH-ROBO, PH-AM, PH-DRUG program IDs |
| [studio-full-implementation-plan.md](../../docs/game-dev/studio-full-implementation-plan.md) | WP-SIM-*, WP-SCI-*, WP-ROBO-*, stub inventory §4 |
| [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md) | Wave 2/11–13 LKIR `@gpu` path (Phase 3) |
| [PH-ML-GPU-execution-tracker.md](../../docs/game-dev/PH-ML-GPU-execution-tracker.md) | Vendor GPU / device buffer gates |
| [li-engine-unified-sim-rfc.md](../../docs/game-dev/specs/li-engine-unified-sim-rfc.md) | `sim_reset` / `sim_step` target API |
| [sim-viz-scientific-rfc.md](../../docs/game-dev/specs/sim-viz-scientific-rfc.md) | `sim.viz` pipeline model |
| [verticals.toml](../../benchmarks/competitive/verticals.toml) | Layer B workload_class / oracle per vertical |
| [2026-05-29-world-studio-master-plan-loop.md](../../docs/superpowers/plans/2026-05-29-world-studio-master-plan-loop.md) | Open WP-SCI-03 / WP-SCI-04 items |
| `scripts/check-mir-gpu-decorator.sh` | `mir_gpu_def=1` gate (decorators only today) |

### `science_gpu` on `main` (verified post-#847)

- **`science_gpu` suite:** Registered in `li-tests/manifest.toml` — **20** tests (`PH-SCI-GPU-01..15` + `16..19` echem/chem DFT). Gate: `scripts/check-science-gpu-gate.sh`.
- **Phase 0 lib compile:** `li-physics-fluids`, `li-physics-em`, `li-physics-weather`, `li-math-numerics` build under `scripts/ph-sci-phase0-gates.sh` (WP-SCI-BUILD-01/02).
- **Honest smokes:** Phase 0 blocked libs import `src/lib.li` exports (WP-SCI-BUILD-03).
- **`@gpu` today:** MIR placement telemetry (`mir_gpu_def=1` via `scripts/check-mir-gpu-decorator.sh`). Vendor LKIR execution remains Phase 3 (WP-SCI-GPU-VENDOR-01).
- **Remaining lib gaps (Phase 2):** `run_algo_registry_stub` for QM (401–432) and non-science registry families; `li-sim-viz` compose-only; scene `native_pixels` stub; particles MD force accumulation still weak.
- **WP-SCI-03 partial (2026-06-08):** CFD (205–210) + FEA (211–216) tier-2 oracles landed; QM rows still stub (418 checksum 1.001 by design until WP-QM-02).

---

## 1. Package audit

**Maturity legend:** stub = counters/contracts only; contract-only = types/APIs without kernels; partial = small proved kernels or oracle smokes; real compute = tier-2 oracle or non-trivial integration with bounded physics.

| Package | Maturity | Test coverage | `lic build` lib | Real vs placeholder | Known blockers |
|---------|----------|---------------|-----------------|---------------------|----------------|
| **li-sim** | contract-only / partial | CPU: `sim_step_stub`, env pool, profile bridge (`compile_open_ok`). No `@gpu`. | Runtime smokes OK; lib large, open VC on strict build | **Real:** deterministic tick/replay/env-pool contracts. **Placeholder:** `SimSessionStub` (no `SimWorld`), `sim_step` increments tick only | Object-call codegen #322 blocks some composables; SIM-4 full replay buffer stub |
| **li-sim-scientific** | partial → tier-2 oracle | CPU + `@gpu` MD oracle smoke | Lib builds with open VC; smokes verify | **Real:** 4-particle LJ chain + 1D heat stencil oracles, `run_multi_physics_at_step`. **Placeholder:** `run_algo_registry_stub` (checksum 1.001) for most registry IDs | WP-SCI-03 registry; CFD/FEA rows stub; no LAMMPS/GROMACS external oracle |
| **li-sim-viz** | stub / contract-only | CPU: `viz_pipeline`, `viz_viewport_fields` (`check_ok`). No `@gpu` | Open VC | **Real:** panel state machine + viewport field compose contract. **Placeholder:** `sim_viz_workload_class_stub`, no wgpu volume/field draw | WP-SCI-04; depends WP-GD-05 wgpu |
| **li-sim-sensors** | partial stub | CPU: `sensor_bus_raycast_contract` | Open VC likely | **Real:** bounded hit distances + session persistence. **Placeholder:** analytic ray distances, not mesh/scene intersection | SIM-5 partial; no lidar mesh |
| **li-sim-robotics** | partial | CPU: `tick_stub`, `workspace_bounds`, `robo_ik_6dof` | Open VC | **Real:** 2-DOF FK, 6-DOF numeric IK step, workspace checks. **Placeholder:** `sim_robotics_tick_at` wraps session + IK, not dynamics/collision | Not Gazebo/MoveIt; WP-ROBO-04/05 open |
| **li-sim-automotive** | partial | CPU: `bicycle_kinematic`, `tick_stub` | Open VC | **Real:** bicycle pose integration. **Placeholder:** tick stub, no maps/odometry | WP-AUTO-02 |
| **li-sim-additive** | partial | CPU: `slicer_workflow`, `sim_export_print`, `tick_stub` | Open VC | **Real:** stage machine + export gate functions. **Placeholder:** no mesh slice geometry, no thermal sim | WP-AM-02 thermal; PH-SCI-2 heat tier-2 for gate |
| **li-sim-drug-design** | stub / contract | CPU: `tick_stub`, LITL composables | Open VC | **Real:** 5-stage LITL indices + ADMET score layout. **Placeholder:** no `chem.dft` queue, no lab ingest | WP-DRUG-04/05; PH-QM |
| **li-physics-core** | contract-only | `builds.li` only | Types/tiers/params — no time step | N/A | Foundation for tier metadata |
| **li-physics-rigid** | partial | `builds.li`, composable `import_physics_runtime` | Open VC | **Real:** semi-implicit integrate, overlap tests. **Placeholder:** single-body game hook | Tier-2 bench vs `rigid_stack_core.c` |
| **li-physics-runtime** | partial | `builds.li`, composable runtime | **Clean build** | **Real:** `physics_world_*`, substep loop, game hook. **Placeholder:** fluids/particles flags unused in full coupling | WP-GAME-02 scene sync |
| **li-physics-particles** | partial (weak) | `builds.li` | Open VC | **Real:** LJ scalar, `md_mini_step` advection. **Placeholder:** `nbody_pair_force` empty body | Not MD force accumulation |
| **li-physics-fluids** | partial | `builds.li` + GPU smoke | **Build OK** (BUILD-01) | **Real:** SPH kernel, euler advect, heat step, PBD distance. **Placeholder:** full SPH sim | WP-SCI-06 cavity; PH-SCI-GPU-04 **done** |
| **li-physics-em** | partial | `builds.li` + GPU smoke | **Build OK** (BUILD-01) | **Real:** Yee Ex update, Jacobi Poisson | PH-SCI-GPU-05 **done** |
| **li-physics-weather** | partial | `builds.li` + GPU smoke | **Build OK** (BUILD-01) | **Real:** advect, diffuse, wind sample | PH-SCI-GPU-07 **done** |
| **li-physics-chem** | partial | `builds.li` | No E0201; open VC | **Placeholder:** `arrhenius_rate` returns `k0` constant | Reaction/combustion loops need review |
| **li-physics-quantum** | partial | `builds.li` | No E0201; open VC | **Real:** normalize_1d, norms. **Placeholder:** no time propagation | PH-SCI-GPU-06 candidate |
| **li-physics-relativity** | partial | `builds.li` | Analytic formulas | No grid simulation | Niche; low sim priority |
| **li-math-numerics** | partial | `builds.li` + GPU smoke | **Build OK** (BUILD-02) | **Real:** Verlet, RK4, CG, three-body | PH-SCI-GPU-01 **done** |
| **li-scene** | partial | `md_particle_tiers`, `md_particle_memory_ledger` (`verify_ok`) | Open VC | **Real:** tier metadata, lig ledger gate, draw tick. **Placeholder:** `native_pixels=0/1` flag only, no GPU particles | PH-SIM #9; WP-UX-13/14 |

**Coupled but out of strict `li-sim-*` audit:** `li-studio` (profile multiplex, scientific viewport sync), `li-ml-rl` + `li-sim` (EnvPool), `li-render`/`lig` (wgpu, not simulation compute).

---

## 2. Gap analysis (themes)

| Theme | Gap | Primary packages |
|-------|-----|------------------|
| **A. Lib compile** | Phase 0 BUILD-01/02/03 **done**; remaining packages still have open VC on strict build | `li-physics-fluids`, `li-physics-em`, `li-physics-weather`, `li-math-numerics` |
| **B. Real physics kernels** | Tier-2 oracles only in `li-sim-scientific`; particles MD force empty; registry mostly stub; no CFD/FEA bench | `li-sim-scientific`, `li-physics-particles`, `verticals.toml` |
| **C. GPU placement vs execution** | `science_gpu` suite on `main` (20 tests); `@gpu` = MIR placement today; vendor LKIR execution Phase 3 | All physics + numerics; pattern in `li-ml/li-tests/smoke/ml_gpu_*.li` |
| **D. Viz / render** | `sim.viz` compose-only; scene `native_pixels` stub; no field/volume draw | `li-sim-viz`, `li-scene`, `li-render`, `li-studio` |
| **E. Sensors** | Raycast analytic stub, no scene mesh | `li-sim-sensors` |
| **F. Robotics** | IK numeric only; no dynamics, ROS2, factory layout | `li-sim-robotics` |
| **G. Automotive** | Bicycle model only | `li-sim-automotive` |
| **H. Additive** | Workflow/export without thermal or real slicer | `li-sim-additive` |
| **I. Drug design** | LITL stage machine without QM/lab | `li-sim-drug-design`, `li-chem` |
| **J. Scientific oracle / multi-physics** | External MD/CFD oracle columns missing; `run_algo_registry_stub` for non MD/heat/rigid IDs | `li-sim-scientific`, WP-PLAT-05 |
| **K. Cross-package integration** | `SimSessionStub` not `SimWorld`; studio hooks `#322`; game physics not scene-synced | `li-sim`, `li-studio`, `li-physics-runtime`, `li-scene` |

---

## 3. Work packages

**Effort:** S ≈ 1–3 days, M ≈ 1–2 weeks, L ≈ multi-week / cross-team.

### Phase 0 — Unblock builds (P0) — **DONE on main**

#### WP-SCI-BUILD-01 — E0201-safe indexing in fluids / em / weather — **DONE**

- **Goal:** `lic build packages/li-physics-{fluids,em,weather}/src/lib.li` succeeds (no E0201).
- **Scope:** `packages/li-physics-fluids/src/lib.li`, `li-physics-em/src/lib.li`, `li-physics-weather/src/lib.li`; package smokes that `import` these modules.
- **Current / gap:** Loops use `while i < 8` with `field[i]` — compiler cannot prove bounds.
- **Deliverables:** Refinement-typed loop indices or unrolled/staged helpers; `physics_*_gpu_progress()` thin wrappers for `@gpu` smokes; update `builds.li` to call one lib function.
- **Dependencies:** None (compiler refinement support as-is).
- **Acceptance:** `lic build packages/li-physics-fluids/src/lib.li` (and em, weather) exit 0; package smokes `compile_open_ok`.
- **Priority / effort:** P0 / M

#### WP-SCI-BUILD-02 — numerics move-semantics (E0311) — **DONE**

- **Goal:** `lic build packages/li-math-numerics/src/lib.li` succeeds.
- **Scope:** `verlet_step_vec2`, `three_body_step_mini`, `rk4_step_4`, `cg_iteration` — `var array` actual parameters.
- **Current / gap:** E0311 on `fy` (and related) after move into callees.
- **Deliverables:** `var` → borrow pattern per language guide; `numerics_three_body_gpu_progress()` for GPU smoke delegation; fix `builds.li` to exercise numerics.
- **Dependencies:** None.
- **Acceptance:** `lic build packages/li-math-numerics/src/lib.li` exit 0; `numerics_gpu_three_body.li` `compile_open_ok` (once WP-SCI-GPU-00 registers suite).
- **Priority / effort:** P0 / M

#### WP-SCI-BUILD-03 — Honest package smokes — **DONE**

- **Goal:** Every audited package `builds.li` imports and calls ≥1 exported `def` from `src/lib.li`.
- **Scope:** All rows in §1 with empty `main` smokes.
- **Deliverables:** Updated `packages/*/li-tests/smoke/builds.li`; manifest notes.
- **Dependencies:** WP-SCI-BUILD-01, WP-SCI-BUILD-02 for blocked libs.
- **Acceptance:** `lic build packages/<pkg>/li-tests/smoke/builds.li` fails if lib broken.
- **Priority / effort:** P0 / S

#### WP-SCI-GPU-00 — Register `science_gpu` suite — **DONE**

- **Goal:** Monorepo `li-tests/manifest.toml` suite `science_gpu` with PH-SCI-GPU IDs (01..15).
- **Scope:** `li-tests/manifest.toml`, `scripts/ci-*` if needed, `li-tests/run_all.sh science_gpu`.
- **Status:** **DONE** — 20 manifest rows on `main`; gate in `scripts/check-science-gpu-gate.sh`.
- **Deliverables:** Manifest block; `scripts/check-science-gpu-gate.sh` wrapping `run_all.sh science_gpu` + optional `check-mir-gpu-decorator.sh`.
- **Dependencies:** WP-SCI-BUILD-01/02 for import paths.
- **Acceptance:** `./li-tests/run_all.sh science_gpu` runs N tests; CI doc link.
- **Priority / effort:** P0 / S

---

### Phase 1 — `@gpu` smokes → real lib compute (P0–P1) — **DONE on `main`** (20 `science_gpu` tests)

Pattern: `@gpu def *_smoke()` → `return <pkg>_*_gpu_progress()` in lib (see `li-ml` `ml_gpu_matmul_stub.li`). Acceptance includes `lic verify` → `mir_gpu_def=1` until vendor path exists.

| WP ID | Title | Packages | Depends | Acceptance (short) | P / Effort |
|-------|-------|----------|---------|-------------------|------------|
| **WP-SCI-GPU-01** | Numerics three-body `@gpu` | `li-math-numerics` | BUILD-02, GPU-00 | `numerics_gpu_three_body.li` compile_open_ok; mir_gpu_def | P0 / S |
| **WP-SCI-GPU-02** | Scientific MD/heat oracle `@gpu` | `li-sim-scientific` | GPU-00 | `scientific_gpu_md_oracle.li`; delegates to oracle checksums | P0 / S |
| **WP-SCI-GPU-03** | Particles MD mini step `@gpu` | `li-physics-particles` | GPU-00 | Real force accumulation in `md_mini_step` + GPU smoke | P1 / M |
| **WP-SCI-GPU-04** | Fluids heat step `@gpu` | `li-physics-fluids` | BUILD-01, GPU-00 | `physics_gpu_fluids_heat_step.li`; lib import OK | P0 / S |
| **WP-SCI-GPU-05** | EM Jacobi `@gpu` | `li-physics-em` | BUILD-01, GPU-00 | `physics_gpu_em_jacobi.li` | P0 / S |
| **WP-SCI-GPU-06** | Quantum normalize `@gpu` | `li-physics-quantum` | GPU-00 | `physics_gpu_quantum_normalize.li` | P1 / S |
| **WP-SCI-GPU-07** | Weather diffuse `@gpu` | `li-physics-weather` | BUILD-01, GPU-00 | `physics_gpu_weather_diffuse.li` | P0 / S |
| **WP-SCI-GPU-08** | Rigid substep `@gpu` | `li-physics-rigid` | GPU-00 | Integrate + overlap smoke | P1 / S |
| **WP-SCI-GPU-09** | Runtime game substep `@gpu` | `li-physics-runtime` | GPU-00 | `physics_world` one substep | P1 / S |
| **WP-SCI-GPU-10** | Scene MD tier draw tick `@gpu` | `li-scene` | GPU-00 | Tier draw + ledger smoke | P2 / S |
| **WP-SCI-GPU-11** | Chem reactor step `@gpu` | `li-physics-chem` | GPU-00 | Fix `arrhenius_rate`; euler step smoke | P2 / M |
| **WP-SCI-GPU-12** | Sensors bus emit `@gpu` | `li-sim-sensors` | GPU-00 | Raycast bus step under `@gpu` | P2 / S |
| **WP-SCI-GPU-13** | Viz pipeline step `@gpu` | `li-sim-viz` | GPU-00 | `viz_pipeline_scientific_step` | P2 / S |
| **WP-SCI-GPU-14** | Automotive bicycle `@gpu` | `li-sim-automotive` | GPU-00 | `sim_automotive_pose_integrate` | P2 / S |
| **WP-SCI-GPU-15** | Robotics IK step `@gpu` | `li-sim-robotics` | GPU-00 | `sim_robotics_session_ik_step` | P2 / S |

**Phase 1 exit:** `./li-tests/run_all.sh science_gpu` all `compile_open_ok`; no test uses empty `import` bypass; fluids/em/weather/numerics libs build.

---

### Phase 2 — Deepen simulation verticals (P1–P2) — **OPEN** (see [ph-sci-gap-close-phase2.md](ph-sci-gap-close-phase2.md))

#### WP-SCI-03 — `run_algo_registry` real kernels (extends existing ID)

- **Goal:** Replace `run_algo_registry_stub` for CFD/FEA/QM rows with real dispatch or tier-2 oracles.
- **Scope:** `li-sim-scientific/src/lib.li`, `benchmarks/competitive/algo_registry.json`, `verticals.toml`.
- **Dependencies:** WP-PLAT-05 (external MD oracle), WP-SCI-05/06.
- **Acceptance:** `run_algo_registry_tier2.li` extended; stub only for explicitly documented IDs.
- **Priority / effort:** P1 / L

#### WP-SCI-04 — `sim.viz` → wgpu field draw (extends existing ID)

- **Goal:** Move from compose-time viewport fields to `li-render` draw list / wgpu path for scientific profile.
- **Scope:** `li-sim-viz`, `li-studio`, `li-render`.
- **Dependencies:** WP-GD-05, PH-HW-2.
- **Acceptance:** `studio_sim_scientific_viz_viewport.li` + render smoke; `native_pixels` readback not stub_pass.
- **Priority / effort:** P1 / L

#### WP-SCI-05 — FEA linear elasticity scaffold

- **Goal:** `fea_linear_elasticity` vertical row with composable + checksum.
- **Scope:** `li-sim-scientific` or new `li-physics-cae` stub package.
- **Dependencies:** WP-PLAT-02 tail.
- **Acceptance:** `verticals.toml` workload_class → `partial`; composable verify_ok.
- **Priority / effort:** P2 / L

#### WP-SCI-06 — CFD lid-driven cavity

- **Goal:** Minimal cavity step kernel + bench row.
- **Scope:** `li-physics-fluids`, `li-sim-scientific`.
- **Dependencies:** WP-SCI-BUILD-01, WP-SCI-05.
- **Acceptance:** cavity smoke + registry algo_id.
- **Priority / effort:** P2 / L

#### WP-SIM-04 — Full `SimWorld` replay buffer

- **Goal:** Entity/state ring buffer beyond tick metadata (SIM-2 extension).
- **Scope:** `li-sim`, `li-world`.
- **Dependencies:** WP-SIM-02 done.
- **Acceptance:** composable replay roundtrip.
- **Priority / effort:** P1 / L

#### WP-SIM-05 — Real sensor raycast (extends partial)

- **Goal:** Scene-backed intersection vs analytic distance.
- **Scope:** `li-sim-sensors`, `li-scene`.
- **Dependencies:** WP-GAME-02.
- **Acceptance:** `sensor_bus_raycast_contract.li` uses scene bounds; hits vary with pose.
- **Priority / effort:** P1 / M

#### WP-AUTO-02 — Lane map + odometry

- **Scope:** `li-sim-automotive`.
- **Acceptance:** composable map tile + odom checksum.
- **Priority / effort:** P2 / L

#### WP-ROBO-03 — IK analytic / better numeric

- **Scope:** `li-sim-robotics` (extends partial numeric IK).
- **Acceptance:** `robo_ik_6dof.li` + workspace proofs tightened.
- **Priority / effort:** P1 / M

#### WP-AM-02 — Thermal gate (`require_sim_pass`)

- **Scope:** `li-sim-additive`, `li-sim-scientific` heat oracle.
- **Acceptance:** `sim_additive_require_sim_pass_ok` uses heat checksum witness.
- **Priority / effort:** P1 / M

#### WP-DRUG-04 — Live `chem.dft` queue

- **Scope:** `li-sim-drug-design`, `li-chem`, `li-studio`.
- **Dependencies:** WP-QM-02.
- **Acceptance:** MCP `chem_dft_run` + stage UI.
- **Priority / effort:** P2 / L

#### WP-GAME-02 — Scene graph ↔ physics sync

- **Scope:** `li-scene`, `li-physics-runtime`, `li-studio`.
- **Acceptance:** composable entity pose matches `game_physics_step_hook`.
- **Priority / effort:** P1 / L

#### WP-PLAT-05 — LAMMPS/GROMACS oracle column

- **Scope:** benchmarks, `li-sim-scientific`.
- **Dependencies:** compliance for `external_binary`.
- **Acceptance:** tier-2 csv column + `md_oracle.toml` driver.
- **Priority / effort:** P1 / L

---

### Phase 3 — Vendor GPU / LKIR path (P2) — **OPEN** (next P0: WP-SCI-GPU-VENDOR-01)

Cross-reference [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md) Waves 2, 11–13, Stage 2.

#### WP-SCI-GPU-VENDOR-01 — Science kernel LKIR lowering pilot

- **Goal:** One science hot loop (e.g. numerics three-body, MD oracle, or **chem DFT density loop** after CHEM-01) emits LKIR like `ml_gpu_lkir_launch.li`.
- **Scope:** `li-math-numerics` or `li-sim-scientific` or `li-chem`, `lig`, compiler `@gpu` backend.
- **Dependencies:** PH-ML Wave 12 T1, WP-SCI-GPU-01/02.
- **Acceptance:** `LIG_EMIT_CUDA=1 lic build …` produces non-empty kernel blob; bench row in `ph-ml-competitive.json`.
- **Priority / effort:** P2 / L

#### WP-SCI-GPU-VENDOR-02 — Device buffer bind for MD grid

- **Goal:** Particle arrays as `lig` device buffers; readback checksum matches CPU oracle.
- **Scope:** `li-physics-particles`, `li-scene`, `lig`.
- **Dependencies:** WP-SCI-GPU-VENDOR-01, WP-SCI-GPU-03.
- **Acceptance:** parity smoke CPU vs GPU buffer readback (tolerance documented).
- **Priority / effort:** P2 / L

#### WP-SCI-GPU-VENDOR-03 — CI gate: science + ML GPU

- **Goal:** Unified gate script: `check-mir-gpu-decorator.sh` + `science_gpu` + `ml_gpu_*` when CUDA available.
- **Scope:** `scripts/`.
- **Dependencies:** WP-SCI-GPU-00, PH-ML program-complete gates.
- **Acceptance:** `ph-sci-gpu-gates.sh` + `check-science-gpu-gate.sh` documented in this file's CI section.
- **Priority / effort:** P2 / S

---

## 4. WP summary

| Phase | WP count | Status | Next P0 |
|-------|----------|--------|---------|
| Phase 0 | 4 | **DONE** (BUILD-01..03, GPU-00) | regression only |
| Phase 1 | 15 | **DONE** (GPU-01..15 on `main`; + GPU-16..19 via #847) | regression only |
| Phase 2 | 11 | **OPEN** | WP-SCI-03 registry |
| Phase 3 | 3 | **OPEN** | WP-SCI-GPU-VENDOR-01 |
| **Total** | **33** | **19 done (~58%)** | |

### Top 3 P0 items (Phase 2 — start here)

1. **WP-SCI-03** — Replace `run_algo_registry_stub` for CFD/FEA/QM rows with real dispatch or tier-2 oracles.
2. **WP-SCI-04** — `sim.viz` → wgpu field draw for scientific profile (depends WP-GD-05).
3. **WP-PLAT-05** — LAMMPS/GROMACS external oracle column for MD tier-2 bench.

---

## 5. Packages not fully assessed

| Package / area | Reason |
|----------------|--------|
| **li-chem** (drug/QM coupling) | Out of `li-sim-*` list; only skimmed via `li-sim-drug-design` import |
| **li-ml-rl** | RL env pool — covered under PH-SIM SIM-3 / PH-ML, not simulation physics |
| **li-render / lig** | wgpu present path — PH-HW / WP-GD-05, not kernel audit |
| **Windows native `lic build`** | Crashed (exit 0xC0000139) in audit shell; WSL `build-wsl` used instead |

---

## 6. Suggested CI commands (post-implementation)

```bash
# Lib compile gate (Phase 0)
./build-wsl/compiler/lic/lic build packages/li-physics-fluids/src/lib.li
./build-wsl/compiler/lic/lic build packages/li-math-numerics/src/lib.li

# MIR placement (Phase 1)
./scripts/check-mir-gpu-decorator.sh
./li-tests/run_all.sh science_gpu

# GPU chem / DFT + echem (cursor/ph-sci-gpu-chem-dft)
bash scripts/ph-sci-gpu-chem-gates.sh
bash scripts/ph-sci-echem-competitive-gates.sh
bash scripts/ph-sci-chem-dft-competitive-gates.sh

# Scientific CPU spine
./li-tests/run_all.sh smoke  # package: li-sim-scientific manifests

# Vendor path (Phase 3, optional CUDA)
LIG_EMIT_CUDA=1 ./build-wsl/compiler/lic/lic build packages/li-ml/li-tests/smoke/ml_gpu_lkir_launch.li
```

---

## 7. Mapping to existing program IDs

| New WP | Existing track |
|--------|----------------|
| WP-SCI-BUILD-* | PH-PLATFORM Wave A (provability / indexing) |
| WP-SCI-GPU-* | PH-SCI / PH-HW / PH-ML-GPU Wave 2 |
| WP-SCI-03..06 | PH-SCI SCI-2..7 (studio plan §3.9) |
| WP-SIM-04/05 | PH-SIM SIM-2/5/6 |
| WP-SCI-GPU-VENDOR-* | PH-ML-GPU battle plan Waves 11–13, Stage 2 |

*Tracking document — Phase 0/1 landed on `main`; Phase 2 kickoff: [ph-sci-gap-close-phase2.md](ph-sci-gap-close-phase2.md).*
