# PH-7e/G-par: decorators → portable parallel lowering (Kokkos-class Host slice)

**Date:** 2026-06-11  
**Gaps:** **G-dec** (Partial), **G-par** (Partial)  
**Issue:** lic#6 — decorators → portable parallel lowering

## Summary

Closes the Host memory-space slice for Kokkos-class portable parallel lowering:

- `@cpu` survives MIR lowering (`mir_cpu_def` telemetry).
- `@cpu` + `@parallel(disjoint=...)` sets `memory_space=Host` on `OmpParallelFor` and codegen calls `li_parallel_for_i64`.
- New `std.execution.parallel` documents memory-space and schedule policy constants.

## Gates

```bash
./scripts/build.sh
./scripts/check-mir-parallel-portable-lowering.sh
./li-tests/run_all.sh stdlib_coverage modules decorators
```

## Not changed

- Device memory-space LKIR lowering (**G-gpu**).
- Distributed multi-GPU Views (**gap-hpc-kokkos-execution-memory-spaces**).
- Lean **P-dec** proofs.
