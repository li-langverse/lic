# HPX-style async futures → Li tier-2 game physics scheduling (G-par)

> **Issue:** [#112](https://github.com/li-langverse/lic/issues/112) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first (structured concurrency + future lifetime laws), **Easy** syntax (`@async` + `Future[T]` surface), **Fast** only after proof (work-stealing overlap for tier-2 physics)  
> **north_star_fit:** Gaming/simulation tier-2 scheduling · **PH-7d**, **PH-7e**, **PH-5b** · **G-par**, **G-async**, **G-physics**  
> **Learned from:** [execution surface spec](../specs/2026-05-25-li-execution-surface.md), [execution decorators](../specs/2026-05-16-li-execution-decorators.md), [parallel design spec](../specs/2026-06-06-li-parallel-design.md), [HPX documentation](https://hpx.stellar-group.org/), [WP-T2 tier-2 physics release](../../release-notes/2026-05-25-tier2-physics-li-builds-wp-t2.md)

## Goal

Close the explorer **missing** rubric for **HPX** (`hpc_libraries[id=hpx].li_status: missing`) by producing a **normative Li-facing plan** that:

1. **Separates** data-parallel `std/execution` decorators (`@parallel`, `@vectorized`, `parallel for`) from **async continuation** scheduling (HPX-style futures).
2. Classifies tier-2 gaming physics kernels into **future-pipeline** vs **bulk `parallel_for`** workloads.
3. Sketches a **Li `Future[T]` + continuation surface** aligned with HPX work-stealing semantics — **no product codegen** in this slice.
4. Documents an optional **benchmarks** HPX reference-driver hook for `rigid_body_stack` / `cloth_swing` (shared-C baseline first).

## Non-goals

- Implementing HPX runtime, distributed PGAS locales, or MPI tasking in **lic**.
- Replacing or duplicating [lic#125](https://github.com/li-langverse/lic/issues/125) (std::execution sender/receiver) or [lic#109](https://github.com/li-langverse/lic/issues/109) (RAJA policy matrix) — those track adjacent abstractions.
- Weakening benchmarks catalog thresholds or claiming green tier-2 perf before proof gates land.
- Editing `trusted.lean` (human-approved issues only).
- Adding GitHub Actions `schedule:` cron.

## Core question (from explorer)

> Does `std/execution` cover **async continuations** or only **data-parallel loops**?

**Answer (normative for this plan):**

| Surface | Scope today | HPX analogue | Gap |
|---------|-------------|--------------|-----|
| `parallel for`, `@parallel(disjoint=…)` | **Data-parallel** iteration independence | HPX `parallel_for` / bulk loops | **G-par** — partial, Lean open |
| `@vectorized(lanes=N)` | **SIMD** within one thread | Vectorized inner loops | **G-par** / **G-dec** |
| `@async` (reserved) | Effect `raises Async` only; **no `await` parse** | HPX `async` launch | **G-async** — partial |
| `Future[T]` + `then` / `continue_with` | **Not in language** | HPX `future` + continuations | **G-async** — missing spec |
| `@executor(pool=…)` | **Not reserved** | HPX thread pools / work stealing | **G-async** — plan target |

**Rule:** Data-parallel decorators **must not** be overloaded to express cross-phase continuations. Tier-2 physics pipelines that need **phase overlap** (broadphase → solve → integrate) require the **future/continuation** track (**G-async**), not `@parallel` alone.

## Distinction from sibling explorer issues

| Issue | Abstraction | This plan (#112) |
|-------|-------------|------------------|
| **lic#125** std::execution | **Sender/receiver** completion channels + algorithm customization | **Lightweight futures** + continuation chains on work-stealing pools |
| **lic#109** RAJA | Static **execution policies** on loop bodies | **Dynamic task graphs** with dependency edges between futures |
| **lic#15** Kokkos-class | Portable `parallel_for` + Views memory spaces | **Async overlap** between physics phases, not loop policy alone |
| **lic#110** Kokkos Views | Strided buffer ABI / execution-space tags | Future payload types for physics buffers — cross-link only |

HPX and std::execution both address tier-2 scheduling; they are **complementary**, not duplicates. Implementers may lower both to OpenMP tasking eventually (PH-7e), but Li surface syntax and proof obligations differ.

## Tier-2 kernel future-pipeline map

Evidence: tier-2 harness rows ([WP-T2 release notes](../../release-notes/2026-05-25-tier2-physics-li-builds-wp-t2.md)), `benchmarks/tier2_physics/`, explorer digest 2026-05-20.

| Kernel / family | Primary pattern | Future-pipeline need | Li v1 surface | Proof axis |
|-----------------|-----------------|----------------------|---------------|------------|
| `rigid_body_stack` | broadphase → constraint solve → integrate | **High** — solve can start while integration prep runs | `async launch` + `Future[ConstraintState]` + `then` | **G-async** + **G-par** on force pass |
| `cloth_swing` | iterative constraints + collision | **High** — constraint iterations chain futures | `Future` per substep; `@parallel` on particle rows inside continuation | **G-async** + **G-par** |
| `euler_fluid_2d` | advect → pressure → project | **High** — staggered phase graph | `when_ready` on pressure after advection future | **G-async** (cross-link lic#125) |
| `combustion_passive` | chemistry substeps + transport | **Medium** | Future per chemistry substep | **G-async** |
| `wind_field_bc` | boundary + field update | **Low** — bulk loops | `@parallel(disjoint=disjoint_row)` only | **G-par** |
| `three_body` / MD integrators | force accumulate + Verlet | **Low** | `@parallel` force loop | **G-par** |
| `ragdoll_chain` | articulated constraints | **Medium** — chain dependencies | Future per link solve (spec sketch) | **G-async** + **G-physics** |

**Rule:** If work items have **explicit happens-before** across phases (constraint result before integrate), model as **future graph**. If inner loop is **iteration-independent**, keep **`parallel for`** + `disjoint=` (**G-par** only).

## Li surface sketch (HPX-aligned, spec-only)

Full normative detail: [HPX async futures surface spec](../specs/2026-06-07-li-hpx-async-futures-surface.md).

### Layer 0 — Reserved names (extends 7d)

| Li surface | HPX analogue | Semantics |
|------------|----------------|-----------|
| `@async` on `def` | `hpx::async` | Launches continuation; `raises Async` required |
| `Future[T]` | `hpx::future<T>` | Typed async result; no `Any` |
| `then(fut, fn)` / `continue_with` | `future::then` | Continuation after ready; borrow proofs required |
| `@executor(pool=physics)` | HPX thread pool / scheduler | Closed pool table; binds work-stealing deque |
| `@parallel(disjoint=…)` | bulk `parallel_for` | **Not** a future; stays data-parallel |

### Layer 1 — Example: rigid body substep

```li
# Sketch — not implemented; syntax subject to 2g/7d parser gates
@executor(pool=physics)
@async
def rigid_body_substep(world: World) -> int
  requires world.valid()
  ensures world.energy_drift_bounded()
  raises Async
=
  let broadphase = async broadphase_pass(world)
  let forces = then(broadphase, |w| schedule_force_pass(w))
  let constraints = then(broadphase, |w| constraint_solve(w))
  await when_all(forces, constraints)   # structured join — see lic#125
  integrate_velocities(world)
  return 0
```

**Proof requirements (G-async):**

- `Future[T]` cannot outlive borrowed `mut` references without proved ordering or `copy` of handles.
- Continuation closures cannot capture conflicting `borrow mut` without disjointness proof.
- Work-stealing pool bounds: max in-flight tasks per `pool=` proved or configured (`[execution] max_tasks`).

### Layer 2 — Backend lowering (PH-7e, future)

| Future context | Lowering target (future) | Depends on |
|----------------|--------------------------|------------|
| Host `pool=physics` | Work-stealing deque + `li_async_poll` | httpd async reactor patterns |
| Host bulk inner loop | OpenMP `parallel for` inside continuation | PH-7b, **G-par** |
| Distributed locale | PGAS / MPI ranks | **G-par-dist** — deferred, human gate |

## Dependencies

| Track | Issue / doc | Role |
|-------|-------------|------|
| Decorator AST | PH-7d, `std/execution/decorators.li` | Reserved `@async`, `@executor` |
| Parallel proofs | PH-7b, **G-par** | Bulk loops inside continuations |
| Structured join | lic#125, **G-async** | `when_all` borrow rules shared |
| Lowering | PH-7e, lic#15, lic#34 | OpenMP task / parallel hybrid |
| Tier-2 harness | PH-5b, WP-T2 | Bench honesty rows |
| Sibling rubrics | lic#109, lic#125 | Cross-link only |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | Normative spec: HPX concept → Li `Future` surface table | Merged spec doc; `check-doc-provability-claims.sh` |
| **B** | Tier-2 kernel future-pipeline matrix (this plan § table) | Linked from issue #112 + `competitive-landscape.md` |
| **C** | MIR **Future** / **Continuation** IR sketch (types only) | Design section in spec; no `lic build` behavior change |
| **D** | **G-async** proof checklist (future lifetime + continuation borrow) | `provability-gaps.md` row update with honest Partial |
| **E** | Benchmarks doc hook: optional `hpx_*` reference driver rows | **benchmarks** catalog doc only; shared-C baseline first |
| **F** | Swarm gap `gap-hpc-hpx-futures-tier2` evidence | Registry YAML + handoff to implementer |

## Tests / benches

| Gate | Command / artifact | When |
|------|-------------------|------|
| Doc honesty | `./scripts/check-doc-provability-claims.sh` | Every PR |
| Tier-2 smoke (unchanged) | `python3 benchmarks/harness/bench.py --tier 2 --only rigid_body_stack,cloth_swing` | After implementation slices |
| Race rejects | `li-tests/race_shared_memory/` | Before any async capture codegen |
| Async effects | `li-tests/effects/` (extend with `Future` + `then` exploits) | Sub-phase C+ |
| Optional reference | benchmarks row `hpx_rigid_body_stack`, `hpx_cloth_swing` (cpp driver, doc-only) | Sub-phase E |

**REQ mapping:**

| REQ | Acceptance |
|-----|------------|
| REQ-async-future-type | `Future[T]` parse + MIR stub; rejects `Future[Any]` |
| REQ-async-then-borrow | `then` rejects conflicting `borrow mut` (compile_fail) |
| REQ-executor-pool-table | `@executor(pool=…)` closed table; unknown pool → compile error |
| REQ-tier2-future-doc | Matrix in spec matches `rigid_body_stack`, `cloth_swing` ids |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-par** | Partial → Partial (honest) | Bulk loops stay on `parallel for`; no future conflation |
| **G-async** | Partial → Partial + plan | Add future lifetime + continuation obligations |
| **G-physics** | Partial → Partial (doc) | Tier-2 extern stubs cite future-pipeline rubric |
| **G-dec** | Partial | `@executor` reserved; exploit suite extended |

## Rollout

1. Merge **this plan PR** (draft → ready) + human **`plan-approved`** on #112.
2. **Spec PR** (sub-phase A) — normative surface only.
3. **Parser/MIR slice** (sub-phase C) — behind `plan-approved`; no runtime until G-async checklist green.
4. **benchmarks** optional HPX reference driver — separate PR in **benchmarks** repo; ingest documentation only.
5. Implementation handoff → `code_implementer` after `plan-approved` + sub-phase A merged.

## Human-only

- [ ] Label **`plan-approved`** on #112 before parser/codegen agents run.
- [ ] Approve `then` vs `continue_with` keyword sugar.
- [ ] Decide whether tier-2 `hpx_*` reference columns are **watch** or **bench_tier2** in `registry.toml`.
- [ ] Distributed HPX locale model — defer until **G-par-dist** has PH track.
