# C++26 std::execution sender/receiver → Li async tier-2 scheduling (G-par, G-ai)

> **Issue:** [#125](https://github.com/li-langverse/lic/issues/125) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first (structured concurrency proofs), **Easy** syntax (decorator-native surface), **Fast** only after proof (async overlap for tier-2 physics)  
> **north_star_fit:** Gaming/simulation tier-2 scheduling · **PH-7d**, **PH-7e**, **PH-5b** · **G-par**, **G-ai**, **G-async**  
> **Learned from:** [execution surface spec](../specs/2026-05-25-li-execution-surface.md), [execution decorators](../specs/2026-05-16-li-execution-decorators.md), [parallel design spec](../specs/2026-06-06-li-parallel-design.md), [LWN systems-language comparison (2025)](https://lwn.net/Articles/1036912/), [MLIR OpenMP dialect](https://mlir.llvm.org/docs/Dialects/OpenMPDialect/)

## Goal

Close the explorer **partial** rubric for **C++ `std::execution`** (P2300 senders/receivers, `par_unseq` algorithm customization) by producing a **normative Li-facing plan** that:

1. Classifies tier-2 physics kernels into **async-overlap pipelines** vs **bulk `parallel_for`** workloads.
2. Sketches a **Li decorator + completion-channel surface** aligned with sender/receiver semantics — **no product codegen** in this slice.
3. Maps proof obligations to **G-par**, **G-async**, and tier-2 **G-ai** bench hooks without weakening `threshold_ratio_cpp`.

## Non-goals

- Implementing P2300 runtime, libstdc++ senders, or CUDA graph drivers in **lic**.
- Replacing or duplicating [lic#112](https://github.com/li-langverse/lic/issues/112) (HPX futures) or [lic#109](https://github.com/li-langverse/lic/issues/109) (RAJA policy matrix) — those track adjacent abstractions.
- Weakening benchmarks catalog thresholds or claiming green tier-2 perf before proof gates land.
- Editing `trusted.lean` (human-approved issues only).
- Adding GitHub Actions `schedule:` cron.

## Distinction from sibling explorer issues

| Issue | Abstraction | This plan (#125) |
|-------|-------------|------------------|
| **lic#109** RAJA | Static **execution policies** on loop bodies (`seq`, `omp parallel`, device) | **Algorithm customization** + **completion channels** across heterogeneous stages |
| **lic#112** HPX | Distributed **futures** + continuation pools | **Structured task graphs** with typed completion (success/error/cancelled) on single-node tier-2 sim loops |
| **lic#34** MLIR omp | Prescriptive OpenMP IR lowering | Sender/receiver **scheduling context** that *feeds* omp/gpu backends via PH-7e |
| **lic#15** Kokkos-class | Portable `parallel_for` + Views | **Overlap** between integrator, constraint, and field stages — not bulk loop policy alone |

## Tier-2 kernel overlap map

Evidence: tier-2 harness rows ([WP-T2 release notes](../../release-notes/2026-05-25-tier2-physics-li-builds-wp-t2.md)), `packages/li-sim-scientific` oracle dispatch, `benchmarks/competitive/verticals.toml` gaming rows.

| Kernel / family | Primary pattern | Async overlap need | Li v1 surface | Proof axis |
|-----------------|-----------------|--------------------|---------------|------------|
| `rigid_body_stack` | Multi-phase: broadphase → solve → integrate | **High** — constraint solve can overlap with integration prep | `@schedule(task)` graph + `@parallel(disjoint=)` force pass | **G-async** + **G-par** |
| `cloth_swing` | Iterative constraints + collision | **High** — constraint iterations pipeline | `when_all` per substep; `@parallel` on particle updates | **G-async** + **G-par** |
| `euler_fluid_2d` | Staggered: advect → pressure → project | **High** — stage graph with completion fences | `@schedule(task)` stages; `@parallel` stencil sweeps | **G-async** + **G-par** |
| `combustion_passive` | Chemistry substeps + transport | **Medium** — substep cadence vs transport | `@schedule(task)` chemistry; `@parallel` transport | **G-async** + **G-par** |
| `wind_field_bc` | Boundary + field update | **Low** — mostly bulk loops | `@parallel(disjoint=)` on grid rows | **G-par** |
| `three_body` / `md_lennard_jones` integrators | Force accumulate + Verlet | **Low** — embarrassingly parallel force loop | `@parallel` + optional `@vectorized` inner | **G-par** |
| `heat_equation_2d` / stencils | Jacobi / explicit steps | **Low** — regular stencil `parallel_for` | `@parallel(disjoint=disjoint_row)` | **G-par** |
| `sim_scientific` MD/heat oracles | Registry dispatch checksum | **Medium** — orchestration only today | `run_algo_registry` → future task graph host | **G-ai** bench hook |

**Rule:** If stages have **data dependencies across phases** (pressure depends on advection), model as **sender graph** with proved happens-before. If inner loop is **iteration-independent**, keep **`parallel for`** + `disjoint=` (**G-par** only).

## Li surface sketch (sender/receiver aligned, spec-only)

Full normative detail: [sender/receiver async scheduling spec](../specs/2026-06-07-li-sender-receiver-async-scheduling-surface.md).

### Layer 0 — Reserved decorators (extends 7d)

| Li decorator | P2300 / std::execution analogue | Semantics |
|--------------|----------------------------------|-----------|
| `@schedule(task, pool=…)` | `schedule(scheduler)` + `then` chain | Single-thread continuation queue; `raises Async` |
| `@schedule(par_unseq, disjoint=…)` | `par_unseq` customization | Maps to existing `@parallel` + `@vectorized` stack |
| `@schedule(par, disjoint=…)` | `par` policy | `parallel for` team on host pool |
| `@on_complete(channel=…)` | receiver `set_value` / `set_error` | Typed completion; no silent swallow |

### Layer 1 — Graph composition (structured concurrency)

```li
# Sketch — not implemented; syntax subject to 2g/7d parser gates
@async(schedule=physics_pool)
def rigid_body_substep(world: World) -> StepResult
  requires world.valid()
  ensures world.energy_bounded()
  raises Async
=

let forces = schedule_force_pass(world)          # Sender<ForceBuf>
let constraints = schedule_constraint_solve(world)  # Sender<ConstraintState>
await when_all(forces, constraints)              # completion channel merge
integrate_velocities(world)
```

**Proof requirements (G-async):**

- `when_all` children cannot capture conflicting `borrow mut` without proved disjointness or ordering.
- Cancellation propagates: parent cancel → children receive `set_stopped` analogue.
- No detached tasks without `raises Async` on enclosing `def`.

### Layer 2 — Backend customization (PH-7e)

| Completion context | Lowering target (future) | Depends on |
|--------------------|--------------------------|------------|
| Host `par_unseq` | OpenMP `parallel for` + SIMD | **lic#34**, PH-7e |
| Host `task` | `li_async_poll` / work-stealing deque | httpd async reactor patterns |
| Device graph | `lig` queue + fence laws | **G-gpu**, lic#15 |

## Dependencies

| Track | Issue / doc | Role |
|-------|-------------|------|
| Decorator AST | PH-7d, `std/execution/decorators.li` | Baseline reserved names |
| Parallel proofs | PH-7b, **G-par** | `disjoint=` for bulk loops |
| Lowering | PH-7e, lic#34, lic#15 | Backend mapping |
| Tier-2 harness | PH-5b, WP-T2 | Bench honesty rows |
| Sibling rubrics | lic#109, lic#112 | Cross-link only |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | Normative spec: P2300 concept → Li surface table | Merged spec doc; `check-doc-provability-claims.sh` |
| **B** | Tier-2 kernel overlap matrix (this plan § table) | Linked from issue #125 + `competitive-landscape.md` |
| **C** | MIR **task-graph** IR sketch (types only, no codegen) | Design section in spec; no `lic build` behavior change |
| **D** | **G-async** proof checklist (structured concurrency) | `provability-gaps.md` row update with honest Partial |
| **E** | Benchmarks doc hook: optional `stdpar` reference driver row | **benchmarks** catalog doc only; no threshold change |
| **F** | Swarm gap `gap-hpc-stdexecution-sender-receiver` evidence | Registry YAML + handoff to implementer |

## Tests / benches

| Gate | Command / artifact | When |
|------|-------------------|------|
| Doc honesty | `./scripts/check-doc-provability-claims.sh` | Every PR |
| Tier-2 smoke (unchanged) | `python3 benchmarks/harness/bench.py --tier 2 --only rigid_body_stack,cloth_swing` | After implementation slices |
| Race rejects | `li-tests/race_shared_memory/` | Before any async capture codegen |
| Async effects | `li-tests/effects/` (extend with `when_all` exploits) | Sub-phase C+ |
| Optional reference | benchmarks row `stdpar_rigid_body_stack` (cpp driver, doc-only) | Sub-phase E |

**REQ mapping:**

| REQ | Acceptance |
|-----|------------|
| REQ-7d-schedule-decorator | `@schedule(task\|par\|par_unseq)` parse + MIR tag stub |
| REQ-async-when-all | `when_all` rejects conflicting borrows (compile_fail) |
| REQ-tier2-overlap-doc | Matrix in spec matches five WP-T2 kernel ids |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-par** | Partial → Partial (honest) | Bulk loops stay on `parallel for`; no async conflation |
| **G-async** | Partial → Partial + plan | Add sender-graph obligations; `await` parse still open |
| **G-ai** | Stub → Partial (doc) | Tier-2 gaming rows cite overlap rubric |
| **G-dec** | Partial | New `@schedule` reserved; exploit suite extended |

## Rollout

1. Merge **this plan PR** (draft → ready) + human **`plan-approved`** on #125.
2. **Spec PR** (sub-phase A) — normative surface only.
3. **Parser/MIR slice** (sub-phase C) — behind `plan-approved`; no runtime until G-async checklist green.
4. **benchmarks** optional reference driver — separate PR; ingest documentation only.
5. Implementation handoff → `code_implementer` after `plan-approved` + sub-phase A merged.

## Human-only

- [ ] Label **`plan-approved`** on #125 before parser/codegen agents run.
- [ ] Approve `@schedule` syntax sugar vs explicit `when_all` keywords.
- [ ] Decide whether tier-2 `stdpar` reference column is **watch** or **bench_tier2** in `registry.toml`.
