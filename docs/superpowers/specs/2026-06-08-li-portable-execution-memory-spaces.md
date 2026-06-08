# Portable execution + memory spaces (spec stub)

**Status:** Plan stub for [#15](https://github.com/li-langverse/lic/issues/15) — **no user syntax change** in this PR  
**Plan:** [2026-06-08-ph7e-gpar-kokkos-class-portable-parallel-lowering-15.md](../plans/2026-06-08-ph7e-gpar-kokkos-class-portable-parallel-lowering-15.md)  
**Gaps:** [G-par](../../verification/provability-gaps.md#g-par), [G-hetero](../../verification/provability-gaps.md#g-hetero), [G-dec](../../verification/provability-gaps.md#g-dec)

## Purpose

Define Kokkos-class **portable** semantics for Li HPC without importing Kokkos:

- **Execution space** — where parallel teams run (host serial, host parallel, device).
- **Memory space** — where array data lives (host, device, unified).
- **Copy policy** — explicit transfers; no silent deep copy in v1.

Decorators remain **compile-time only** ([execution decorators spec](2026-05-16-li-execution-decorators.md)).

## ExecutionSpace (compiler + runtime tag)

| Variant | Decorator / keyword signal | Runtime |
|---------|------------------------------|---------|
| `HostSerial` | default; `@serial` (future) | single-thread |
| `HostParallel` | `@cpu` + `@parallel` / `parallel for` | `li_parallel_for_*` (→ OpenMPIRBuilder per #34) |
| `Device` | `@gpu` / `@gpu(devices=N)` | placement metadata; codegen via #34 / #116 tracks |

## MemorySpace (buffer policy)

| Variant | Meaning | Copy rule (v1) |
|---------|---------|----------------|
| `Host` | Ordinary host arrays | default for `@cpu` |
| `Device` | Device-resident buffers | requires explicit `copy_to_device` / allocation API (**#110** View ABI) |
| `Unified` | Unified memory (optional) | opt-in; documented perf caveats |

**Binding:** If a loop is tagged `Device` execution but reads `Host` memory without an explicit copy in the proof corpus, **`lic build` fails** (compile error — not runtime UB).

## Decorator stacks (orthogonal axes)

| Stack | Elaboration |
|-------|-------------|
| `@cpu` `@parallel(disjoint=d)` | HostParallel + `ParallelFor` |
| `@cpu` `@parallel` `@vectorized(lanes=4)` | HostParallel teams **and** inner SIMD scope (phase 07 §7d) |
| `@gpu` `@parallel(disjoint=d)` | Device tag + parallel MIR; offload IR deferred (#34, #116) |

`@vectorized` **never** spawns parallel teams (see `std/execution/decorators.li`).

## Relationship to Kokkos

Li does **not** embed Kokkos. This spec captures the **minimum** capability checklist the HPC rubric expects:

- portable `parallel_for` over a range with execution-space policy;
- named memory spaces with explicit migration;
- hierarchical parallelism via decorator stacks (teams + SIMD), not Kokkos `TeamPolicy` syntax.

Full View layout / stride ABI is **#110**, not this stub.

## Open questions (human review)

1. Should `Unified` be in v1 or deferred until G-gpu address-space proofs exist?
2. Minimum tier-2 row for first `pure_li` migration: `heat_equation_2d` vs MD kernel?
3. Alignment with PETSc–Kokkos exascale doc ([#28](https://github.com/li-langverse/lic/issues/28)) for sync-point isolation.
