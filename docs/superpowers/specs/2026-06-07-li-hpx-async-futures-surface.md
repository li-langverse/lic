# HPX-style async futures → Li tier-2 physics scheduling surface (requirements)

**Date:** 2026-06-07  
**Status:** Normative requirements (planning slice for lic#112)  
**Issue:** [lic#112](https://github.com/li-langverse/lic/issues/112)  
**Plan:** [2026-06-07 HPX futures tier-2 plan](../plans/2026-06-07-li-hpx-futures-tier2-physics-scheduling.md)  
**Related:** [execution surface](2026-05-25-li-execution-surface.md), [execution decorators](2026-05-16-li-execution-decorators.md), [parallel design](2026-06-06-li-parallel-design.md), [lic#125](https://github.com/li-langverse/lic/issues/125), [lic#109](https://github.com/li-langverse/lic/issues/109), [lic#15](https://github.com/li-langverse/lic/issues/15)  
**PH / G:** PH-7d, PH-7e, PH-5b · **G-par**, **G-async**, **G-physics**  
**Intel:** [HPX](https://hpx.stellar-group.org/), explorer `hpc_libraries[id=hpx]`, [WP-T2 tier-2 physics](../../release-notes/2026-05-25-tier2-physics-li-builds-wp-t2.md)

## Problem

**HPX** provides **lightweight futures**, **continuation-based scheduling**, and **work-stealing thread pools** for fine-grained task parallelism — the dominant pattern in tier-2 game physics when shared-C kernels wrap multi-phase sim loops. Li today has:

- Proved **`parallel for`** + `@parallel` / `@vectorized` (**G-par**)
- Reserved `@async` with `raises Async` effect — **no `await`, no `Future[T]`**
- Tier-2 physics wrappers (`rigid_body_stack`, `cloth_swing`, …) that compile and checksum but use **sequential** `extern` orchestration

Explorer marks HPX as **missing**. This spec defines **Li-facing requirements** so PH-7d can add async futures without conflating them with data-parallel decorators.

!!! note "Provability status"
    Li does **not** claim HPX parity. Requirements are **targets** with explicit done gates. See [Provability gaps](../../verification/provability-gaps.md) (**G-async**, **G-par**).

## Decorator vs future boundary (normative)

| User intent | Li surface | Must NOT use |
|-------------|------------|--------------|
| Independent loop iterations | `parallel for` / `@parallel(disjoint=…)` | `Future` per iteration |
| SIMD inner dimension | `@vectorized(lanes=N)` | `@async` on inner `for` |
| Cross-phase overlap (physics pipeline) | `async` + `Future[T]` + `then` | `@parallel` on enclosing `def` alone |
| Structured join of N async stages | `when_all` (shared with lic#125) | Detached threads without `raises Async` |

**REQ-decorator-future-separation:** Compiler **must reject** `@parallel` on `def` that returns `Future[T]` without an inner proved `parallel for` — prevents policy-string HPX emulation.

## Concept mapping (HPX → Li)

| HPX concept | Li requirement | Proof hook |
|-------------|----------------|------------|
| `hpx::future<T>` | `Future[T]` typed handle; no `Any` | **G-async** — lifetime + readiness |
| `hpx::async(f)` | `@async def` or `async expr` launching `Future` | `raises Async` mandatory |
| `future::then` | `then(fut, fn)` or `continue_with` sugar | Continuation borrow checker |
| Thread pool / scheduler | `@executor(pool=physics)` on `def` or module | Closed pool table |
| `parallel_for` bulk | `parallel for` + `@parallel` | **G-par** disjoint lemmas |
| Distributed `future` across localities | Deferred | **G-par-dist** — not v1 |

## Tier-2 workload classification

### Future-pipeline workloads (HPX-class)

| Workload | Phases | Future graph rationale |
|----------|--------|------------------------|
| `rigid_body_stack` | broadphase → constraints → integrate | Constraint solve can pipeline with integration prep |
| `cloth_swing` | stretch/shear ↔ collision iterations | Substep chains benefit from continuation pools |
| `ragdoll_chain` | per-link articulated solve | Dependency chain along kinematic tree |
| `euler_fluid_2d` | advect → pressure → project | Staggered scheme — cross-link lic#125 `when_all` |

**Requirement:** Each phase launch returns `Future[PhaseState]`. Parent continuations must prove **happens-before** on shared `World` borrows.

### Bulk `parallel_for` workloads (not futures)

| Workload | Hot loop | Surface |
|----------|----------|---------|
| `wind_field_bc` | boundary face updates | `@parallel(disjoint=disjoint_row)` |
| `three_body` / MD forces | all-pairs inner | `@parallel` + optional `@vectorized` |
| `heat_equation_2d` | stencil rows | `@parallel(disjoint=disjoint_row)` |

**Requirement:** Do **not** wrap iteration-independent loops in `Future` — preserves **G-par** path.

## Surface syntax (v1 sketch)

### Reserved decorators

```li
@executor(pool=physics)   # work-stealing pool binding
@async                    # requires raises Async on enclosing def
```

- `pool=` closed table (v1): `physics`, `io`, `default`, `compile` (compile farm is CLI-only — never `pool=compile` at runtime).
- Unknown `pool=` → **compile error**.

### Future types and operations

| Form | Meaning | Status |
|------|---------|--------|
| `Future[T]` | Async result handle | Spec **v1** |
| `async expr` | Launch expression as future | Spec **v1** |
| `then(fut, fn)` | Continuation when ready | Spec **v1** |
| `await fut` | Block until `Future[T]` ready | Parser **open** (shared lic#125) |
| `when_all(fut_a, fut_b, …)` | Structured join | Cross-ref lic#125 |

### Example: cloth constraint substep

```li
@executor(pool=physics)
@async
def cloth_substep(mesh: ClothMesh) -> int
  requires mesh.valid()
  ensures mesh.max_strain_bounded()
  raises Async
=
  let stretch = async solve_stretch_constraints(mesh)
  let collision = then(stretch, |m| solve_collision(m))
  await collision
  return 0
```

## MIR / codegen requirements (future slices)

| MIR node | Purpose | Lowers to (v1 host) |
|----------|---------|---------------------|
| `AsyncLaunch` | Start future | Pool push + refcount |
| `FutureThen` | Continuation edge | Work-stealing deque item |
| `FutureAwait` | Suspend until ready | State machine + `li_async_poll` |
| `ExecutorPool` | Pool tag on `def` | Static pool id in MIR metadata |

**No codegen in lic#112 plan slice** — MIR names are placeholders for implementer handoff.

## Benchmark / ecosystem hooks

| Artifact | Repo | Action |
|----------|------|--------|
| Tier-2 future-pipeline matrix | **lic** (this spec) | Doc-only |
| Optional `hpx_rigid_body_stack`, `hpx_cloth_swing` | **benchmarks** | `watch` column; shared-C kernel first |
| Explorer rubric | **benchmarks** `hpc_libraries[id=hpx]` | Update `li_status` to `partial` after spec merge |

## Done criteria (plan-approved → implement)

- [ ] `@executor` + `Future[T]` documented in `std/execution/decorators.li` comment block
- [ ] `then` compile_fail seeds for borrow conflict (≥2 fixtures)
- [ ] `provability-gaps.md` **G-async** row cites this spec
- [ ] `rigid_body_stack` + `cloth_swing` future-pipeline rows reviewed by physics maintainer
- [ ] Cross-link to lic#125 `when_all` spec — no duplicate join semantics
