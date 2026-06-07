# std::execution sender/receiver → Li async scheduling surface (requirements)

**Date:** 2026-06-07  
**Status:** Normative requirements (planning slice for lic#125)  
**Issue:** [lic#125](https://github.com/li-langverse/lic/issues/125)  
**Plan:** [2026-06-07 tier-2 scheduling plan](../plans/2026-06-07-li-stdexecution-sender-receiver-tier2-scheduling.md)  
**Related:** [execution surface](2026-05-25-li-execution-surface.md), [execution decorators](2026-05-16-li-execution-decorators.md), [parallel design](2026-06-06-li-parallel-design.md), [lic#109](https://github.com/li-langverse/lic/issues/109), [lic#112](https://github.com/li-langverse/lic/issues/112), [lic#34](https://github.com/li-langverse/lic/issues/34)  
**PH / G:** PH-7d, PH-7e, PH-5b · **G-par**, **G-async**, **G-ai**  
**Intel:** [P2300 std::execution](https://wg21.link/P2300), [LWN systems languages 2025](https://lwn.net/Articles/1036912/), [MLIR OpenMP dialect](https://mlir.llvm.org/docs/Dialects/OpenMPDialect/), explorer `hpc_libraries[id=stdpar]`

## Problem

C++26 **`std::execution`** treats **sender/receiver** completion channels and **algorithm customization** (`par`, `par_unseq`, `task`) as the baseline for heterogeneous simulation loops. Li today has **decorator AST only** (`std/execution/decorators.li`) plus proved **`parallel for`** — no first-class **async task graph** with typed completion for tier-2 gaming physics (`rigid_body_stack`, `cloth_swing`, `euler_fluid_2d`).

This spec defines **Li-facing requirements** so PH-7d/7e can extend decorators without breaking provability-first ordering.

!!! note "Provability status"
    Li does **not** claim P2300 parity. Requirements are **targets** with explicit done gates. See [Provability gaps](../../verification/provability-gaps.md) (**G-async**, **G-par**).

## Concept mapping (P2300 → Li)

| std::execution concept | Li requirement | Proof hook |
|------------------------|----------------|------------|
| **Scheduler** | Execution resource axis (`cores`, `threads_per_core`, future device queue) | [execution resources](2026-05-25-li-execution-resources.md) |
| **Sender** | `def` tagged `@schedule(task)` returning typed **Task[T]** (spec-only type) | **G-async** — totality + `raises Async` |
| **Receiver** | `await` / `@on_complete` lowering to state machine | Structured concurrency laws |
| **`then` / `let_value`** | `await` chain or `then` sugar on `Task` | No implicit `Any`; effects tracked |
| **`when_all`** | N-ary merge with borrow/disjoint proof | Compile_fail on conflicting `borrow mut` |
| **`when_any`** | Deferred — requires cancellation proof | Human gate |
| **`par_unseq`** | `@schedule(par_unseq, disjoint=…)` → `@parallel` + `@vectorized` | **G-par** disjoint lemmas |
| **`par`** | `@schedule(par, disjoint=…)` → `parallel for` team | **G-par** |
| **Algorithm customization** | Decorator stack on `def` / `parallel for` (top-to-bottom) | **G-dec** exploit suite |

## Tier-2 workload classification

### Async-overlap pipelines (sender graph)

| Workload | Stages | Overlap rationale |
|----------|--------|-------------------|
| `rigid_body_stack` | collision → constraints → integration | Constraint setup overlaps with force write-back |
| `cloth_swing` | stretch/shear constraints ↔ collision response | Iterative solve benefits from pipelined substeps |
| `euler_fluid_2d` | advect → pressure Poisson → projection | Classic staggered scheme; stage fences required |
| `combustion_passive` | reaction substeps ↔ scalar transport | Different time scales |

**Requirement:** Each stage is a **Sender** with explicit completion (`ok` / `err` / `stopped`). Parent `when_all` must not introduce data races — borrow checker + `disjoint=` on parallel substages.

### Bulk `parallel_for` (no sender graph)

| Workload | Hot loop | Surface |
|----------|----------|---------|
| `wind_field_bc` | boundary face updates | `@parallel(disjoint=disjoint_row)` |
| `three_body` / MD forces | all-pairs or stencil inner | `@parallel` + `@vectorized` inner |
| `heat_equation_2d` | 5-point stencil rows | `@parallel(disjoint=disjoint_row)` |

**Requirement:** Do **not** force sender/receiver wrapping on iteration-independent loops — preserves **G-par** proof path and codegen simplicity.

## Surface syntax (v1 sketch)

### Reserved decorator: `@schedule`

```li
@schedule(task, pool=physics)   # host continuation queue
@schedule(par, disjoint=disjoint_elem)
@schedule(par_unseq, disjoint=disjoint_elem)  # implies vectorized inner where legal
```

- Parsed at compile time only — **no runtime decorator registry**.
- Illegal stacks (e.g. `@schedule(task)` under `@schedule(par_unseq)` on same `def`) → **compile error**.
- `pool=` names a **closed table** of runtime queues (v1: `physics`, `io`, `default`) — no user-defined strings without package prefix.

### Structured concurrency primitives (keywords)

| Form | Meaning | Status |
|------|---------|--------|
| `await expr` | Suspend until `Task[T]` completes | Parser **open** |
| `when_all(a, b, …)` | Wait for all senders; merge results | Spec **v1** |
| `when_any(…)` | First completion wins | **Deferred** |

### Example: rigid body substep

```li
@schedule(task, pool=physics)
@async
def rigid_body_substep(w: World) -> int
  requires w.valid()
  ensures w.energy_drift_bounded()
  raises Async
=
  let f = schedule_forces(w)
  let c = schedule_constraints(w)
  await when_all(f, c)
  integrate(w)
  return 0
```

## MIR / codegen requirements (future slices)

| MIR node | Purpose | Lowers to (v1 host) |
|----------|---------|---------------------|
| `ScheduleTask` | Continuation entry | `li_async_poll` work item |
| `WhenAll` | Join N senders | deque + refcount (proved bounded) |
| `OnComplete` | Receiver hook | State machine branch |
| `ParUnseqScope` | Policy tag | OpenMP + SIMD scope (PH-7e) |

**No codegen in lic#125 plan slice** — MIR names are placeholders for implementer handoff.

## Benchmark / ecosystem hooks

| Artifact | Repo | Action |
|----------|------|--------|
| Tier-2 kernel matrix | **lic** (this spec) | Doc-only |
| Optional `stdpar_*` reference row | **benchmarks** | `watch` column; parity documentation |
| Explorer rubric | **benchmarks** `hpc_libraries[id=stdpar]` | Update `li_status` after spec merge |

## Done criteria (plan-approved → implement)

- [ ] `@schedule` reserved in `std/execution/decorators.li` comment block + parser whitelist
- [ ] `when_all` compile_fail seeds for borrow conflict (≥2 fixtures)
- [ ] `provability-gaps.md` **G-async** row cites this spec
- [ ] Tier-2 five-kernel overlap table reviewed by physics maintainer
- [ ] No `threshold_ratio_cpp` changes in benchmarks

## Learned from

| System | Li adaptation |
|--------|---------------|
| C++ P2300 | Completion channels → `Task[T]` + `await`; no type-erased senders |
| HPX futures | Distinct — futures are remote/async; we start single-node tier-2 graphs |
| RAJA policies | `par`/`par_unseq` map to decorator stack, not policy template metaprogramming |
| Chapel locales | Deferred — distribution is out of v1 scope |
| li-httpd async | Reuse `li_async_poll` reactor patterns for `schedule(task)` host queue |
