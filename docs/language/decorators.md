# Execution decorators

**Handbook:** [Parallelism](parallelism.md). **Surface:** [execution surface](../superpowers/specs/2026-05-25-li-execution-surface.md).

Li attaches **execution decorators** to `def` and to `for` / `while` loops with `@name` syntax (see [execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)).

## Reserved names

Names such as `parallel`, `vectorized`, `async`, `cpu`, and `gpu` are reserved for the standard library. User-defined decorators must use distinct names (minimum length enforced at compile time).

## Parallel loops

`@parallel` on a `parallel for` loop requires a disjointness proof hint, e.g. `disjoint_elem(i, buf)` in the loop contract list.

## Status

Parsing, policy checks, and **MIR proc tags** are implemented in `lic build` / `lic verify`:

| Decorator | MIR tag | Verify telemetry | Gate script |
|-----------|---------|------------------|-------------|
| `@cpu` | `MirDecorator.cpu` | `mir_cpu_def` | `check-mir-cpu-decorator.sh` |
| `@parallel(disjoint=…)` | `MirDecorator.parallel` + `disjoint_proven` | `mir_parallel_disjoint` | `check-mir-parallel-decorator.sh` |
| `@vectorized(lanes=N)` | `MirDecorator.vectorized` | `mir_vectorized_proc` | `check-mir-vectorized-decorator.sh` |
| `@gpu(devices=N)` | `MirDecorator.gpu` | `mir_gpu_def` | `check-mir-gpu-decorator.sh` |

Def-level `@parallel(disjoint=…)` inherits disjointness to nested `parallel for` loops (policy witness — see **G-par**). Full Lean **P-dec** discharge and LKIR `@gpu` codegen remain open (**G-dec** / **G-gpu** partial).

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
