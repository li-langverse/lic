# Portable parallel lowering (PH-7e / lic#6)

**Issue:** [lic#6](https://gitlab.lilangverse.xyz/li-langverse/lic/-/issues/6) · **Gaps:** G-dec, G-par, G-math (Phase 7d–7e)

## Summary

Closes the **Kokkos-class portable parallel lowering** slice for execution decorators on shared-memory CPU:

- `@parallel(disjoint=…)` elaborates to MIR `OmpParallelFor` and lowers to portable `li_parallel_for_i64` (native thread pool; no user OpenMP pragma surface).
- `@cpu` / `@gpu` map to compile-time memory-space policy constants in `std/execution/memory_spaces.li`.
- Master-plan gate `scripts/check-mir-portable-parallel-lowering.sh` ties decorator smoke + LLVM IR evidence.

## Still open (deferred)

- Kokkos Views / distributed multi-GPU memory spaces (`gap-hpc-kokkos-execution-memory-spaces`).
- `@gpu` LKIR/kernel codegen and address-space proofs (G-gpu).

## Tests

```bash
bash scripts/check-mir-portable-parallel-lowering.sh
bash li-tests/run_all.sh decorators
```
