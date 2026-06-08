# ADR: MLIR `omp` dialect for `@gpu` offload (stub)

**Status:** Proposed — design only ([#34](https://github.com/li-langverse/lic/issues/34) sub-phase **D**)  
**Date:** 2026-06-08  
**Depends on:** [parallel-lowering-map.md](../../language/parallel-lowering-map.md), [execution decorators](2026-05-16-li-execution-decorators.md)  
**Blocks:** G-gpu LKIR offload; does **not** block host CPU OpenMPIRBuilder track

## Context

Li decorators (`@cpu`, `@gpu`, `@parallel`, `@vectorized`) elaborate to MIR today. Host parallel loops call `li_par_pool`; GPU placement is MIR telemetry only. Upstream LLVM provides:

- **OpenMPIRBuilder** for host OpenMP IR in LLVM dialect.
- **MLIR `omp` dialect** for portable OpenMP semantics including `omp.target` offload.

[#34](https://github.com/li-langverse/lic/issues/34) requires a single decorator story that can lower to both without Kokkos-style duplicate abstractions ([#15](https://github.com/li-langverse/lic/issues/15) consumes this map for policy).

## Decision (proposed)

1. **Host `@cpu` / `parallel for`:** LLVM IR via OpenMPIRBuilder (see handbook §2). No MLIR stage in v1 host path.
2. **Device `@gpu`:** When G-gpu codegen lands, insert an MLIR lowering pass:
   - MIR `OmpParallelFor` inside `@gpu` region → `omp.target` wrapping `omp.parallel` + `omp.wsloop`.
   - Buffer captures → `omp.target_data` with `map` clauses derived from MIR `par_captures`.
3. **Export:** MLIR → LLVM IR (OpenMPIRBuilder for host regions; NVPTX/AMDGPU backend for device) — exact backend matrix is G-gpu scope.
4. **Proof:** Device address-space separation remains in Lean (`G-gpu`); MLIR is transport only — no `unsafe` / `Any`.

## Non-decisions (deferred)

- SPIR-V vs CUDA vs HIP first backend.
- `omp.requires` / unified shared memory.
- `omp.task` for `@async`.

## Spike exit criteria

| Gate | Command / artifact |
|------|-------------------|
| MLIR parse smoke | `mlir-opt` round-trip on hand-written `omp.parallel` + `omp.wsloop` from Li MIR dump |
| Host parity | `LI_CODEGEN_OMP_IR=1` matmul row within 1.2× pool path |
| `@gpu` stub | `lic verify` on `@gpu` sample prints `mir_gpu_def=1`; no device link required in spike |

## Consequences

- **Positive:** One LLVM/MLIR upstream map for G-par portable semantics; tier-2 OpenMP scaling columns become honest.
- **Negative:** Second codegen pipeline stage; CI must pin MLIR/LLVM versions.
- **Risk:** OpenMP 5 `target` semantics vs Li proof model — human review required before enabling in release builds.

## References

- [MLIR OpenMP dialect](https://mlir.llvm.org/docs/Dialects/OpenMPDialect/)
- [OpenMPIRBuilder](https://llvm.org/doxygen/classllvm_1_1OpenMPIRBuilder.html)
- [parallel-lowering-map.md §4](../../language/parallel-lowering-map.md#4--target-mlir-omp-dialect-offload-sketch)
