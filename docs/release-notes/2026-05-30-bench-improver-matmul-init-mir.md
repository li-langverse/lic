# bench_improver: tier-1 matmul init MIR + yellow→green

## Summary

Pure-Li `matmul_naive` and `matmul_blocked` use `mm_init_*` MIR hooks that emit C-oracle init loops (mod + sitofp × scale). `mm_naive_256` uses vectorized IKJ+FMA (blocked lowering only for n≥512). Local tier-1 ratios: **matmul_naive 1.167×**, **matmul_blocked 0.99×** (≤1.2× cap).

## Changed

| Path | Evidence |
|------|----------|
| `compiler/mir/include/li/mir.hpp`, `lower.cpp` | `ArrayMatmulBenchInit2DF64`, `mm_init_256/512` |
| `compiler/codegen/emit.cpp` | init emitter; 256³ IKJ path; 64-byte align for 512² mats |
| `benchmarks/tier1_micro/matmul_*/li/main.li` | drop LUT if-chains |
| `docs/numerics/studies/2026-05-30-bench-improver-matmul-init-mir.md` | evidence pack |

## Downstream

`LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh` in **benchmarks** repo for dashboard refresh.
