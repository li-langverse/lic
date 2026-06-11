# Execution decorators

**Handbook:** [Parallelism](parallelism.md). **Surface:** [execution surface](../superpowers/specs/2026-05-25-li-execution-surface.md).

Li attaches **execution decorators** to `def` and to `for` / `while` loops with `@name` syntax (see [execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)).

## Reserved names

Names such as `parallel`, `vectorized`, `async`, `cpu`, and `gpu` are reserved for the standard library. User-defined decorators must use distinct names (minimum length enforced at compile time).

## Parallel loops

`@parallel` on a `parallel for` loop requires a disjointness proof hint, e.g. `disjoint_elem(i, buf)` in the loop contract list.

## Portable parallel lowering (PH-7e)

`@parallel(disjoint=…)` on `def` / `parallel for` elaborates to MIR `OmpParallelFor` and lowers to portable **`li_parallel_for_i64`** (native thread pool linked by `lic build`). No user-facing OpenMP pragma surface.

`@cpu` and `@gpu` attach compile-time **memory-space policy** (host `0` / device `1` accessors in `std/execution/memory_spaces.li`). `@gpu` placement metadata is visible in MIR telemetry; LKIR/device-buffer codegen remains **G-gpu**.

Gate: `scripts/check-mir-portable-parallel-lowering.sh`.

## Status

Parsing, policy, and **7d-b–e MIR lowering** are implemented in `lic build`. Exit gate: `./scripts/check-mir-decorator-lowering.sh` (**G-dec** closed slice). **`@cpu` + `@parallel(disjoint=...)`** lower to portable Host `li_parallel_for_i64` (Kokkos-class memory-space policy in `std/execution/memory_spaces.li` and `std.execution.parallel`; **G-par** cross-link). **`@gpu`** records Device placement in MIR telemetry; vendor LKIR lowering remains **G-gpu**. See [provability-gaps](../verification/provability-gaps.md) (**G-dec**, **G-par**).

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
