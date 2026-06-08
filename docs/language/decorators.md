# Execution decorators

**Handbook:** [Parallelism](parallelism.md). **Surface:** [execution surface](../superpowers/specs/2026-05-25-li-execution-surface.md).

Li attaches **execution decorators** to `def` and to `for` / `while` loops with `@name` syntax (see [execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)).

## Reserved names

Names such as `parallel`, `vectorized`, `async`, `cpu`, and `gpu` are reserved for the standard library. User-defined decorators must use distinct names (minimum length enforced at compile time).

## Parallel loops

`@parallel` on a `parallel for` loop requires a disjointness proof hint, e.g. `disjoint_elem(i, buf)` in the loop contract list.

## Status

Parsing and policy checks are implemented in `lic check`. MIR elaboration and codegen lowering are tracked as **G-dec** in [provability-gaps](../verification/provability-gaps.md).

## Execution policy matrix (PH-7e)

`@parallel(disjoint=…)` on `parallel for` lowers to a **static-chunk** host team (`li_parallel_for_i64` with `LI_PAR_SCHEDULE=static` default). `lic verify` reports `mir_parallel_policy=static_chunk` when a proved disjoint loop is present — no silent serial fallback when `LI_PARALLEL=1`.

Normative cross-framework mapping (Li → RAJA → Kokkos → OpenMP): [RAJA policy portability rubric](../superpowers/specs/2026-06-07-li-raja-policy-portability-rubric.md) (lic#109). Tier-1 anchor kernel: `reduce_sum` (RP-04 in rubric).

## Resource knobs (`lic build`)

These are **CLI flags**, not decorators:

| Flag | Role |
|------|------|
| `--jobs=N` | Parallel compile workers (isolated `--build-dir` trees) |
| `--cores=N` | Hardware cores for the runtime parallel team |
| `--threads-per-core=M` | Logical threads per core (default 1); team size = min(N×M, 64) |
| `--threads=N` | Total runtime parallel team; wins over `--cores` when both are set |
| `@vectorized(lanes=4)` | SIMD lane width inside one core — LLVM vectors only, no `li_parallel_for_i64` |

Prefer flags over deprecated `LI_COMPILE_JOBS`, `LI_OMP_THREADS`, etc.
