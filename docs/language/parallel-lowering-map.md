# Parallel lowering map (Li → MIR → LLVM / MLIR)

> **Status:** Skeleton — filled by [#34](https://github.com/li-langverse/lic/issues/34) implementation track  
> **Normative plan:** [2026-06-07-std-execution-openmp-mlir-lowering-map.md](../superpowers/plans/2026-06-07-std-execution-openmp-mlir-lowering-map.md)

This page is the **handbook-facing** lowering map for `std/execution` decorators and `parallel for`. Compiler agents maintain the tables; users read this for mental model only (decorators remain compile-time).

## §1 — Current lowering (inventory)

| Source surface | Elaboration | MIR | Codegen (`emit.cpp`) | Runtime |
|----------------|-------------|-----|----------------------|---------|
| `parallel for i in a..<b` | policy `disjoint_*` | `OmpParallelFor` | `li_parallel_for_i64(start, end, fn, team)` | `li_par_pool.c` |
| `@parallel(disjoint=d)` on `def` | inherits to nested `parallel for` | same | same | same |
| `@vectorized(lanes=4)` on `for` | `ArraySimdScope` | `Simd*` ops | `<4 x double>` LLVM vectors | none |
| `--cores` / `--threads-per-core` | CLI | `runtime_team_size` | i32 arg to `li_parallel_for_i64` | `LI_OMP_THREADS` env alias |

See `compiler/mir/lower.cpp` (`ParallelFor`), `compiler/codegen/emit.cpp` (`OmpParallelFor`), `runtime/li_par_pool.c`.

## §2 — Target: OpenMPIRBuilder (host CPU)

_Pending implementation — see plan sub-phase **B**._

Planned mapping:

- `OmpParallelFor` → `OpenMPIRBuilder::createParallel` + `createLoop` (static schedule v1).
- Team size → OpenMP `num_threads` from `[execution]` / CLI knobs.
- Reductions → `createReduction` when 7e reduction MIR ops gain par variants.

## §3 — SIMD orthogonality

`@vectorized` **never** emits `OmpParallelFor` or OpenMP `simd` directives in v1. Proof story for auto-vectorization vs explicit lanes remains **G-math** / **G-dec**.

## §4 — Target: MLIR `omp` dialect (offload sketch)

_Pending ADR — see plan sub-phase **D**._

Future `@gpu` regions may lower MIR → MLIR `omp.target` before LLVM IR export. Host `@cpu` stays on OpenMPIRBuilder path only.

## §5 — G-par IR witnesses

`MirInsn::parallel_disjoint_proven` (set in `lower.cpp`) must survive lowering as inspectable metadata (`lic verify` telemetry). Design TBD in plan sub-phase **E**.
