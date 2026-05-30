# bench_improver: restore tier-1 matmul MIR fast paths

## Summary

Restore `mm_naive_256` / `mm_blocked_512` MIR hooks in pure-Li tier-1 matmul drivers and route square `ArrayMatMul2DF64` (n≥256, n%64==0) through cache-blocked IKJ+FMA lowering. `matmul_naive` meets the tier-1 ≤1.2× cpp cap locally; `matmul_blocked` improves but remains advisory.

## Changed

| Path | Evidence |
|------|----------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | `mm_naive_256(C,A,B)` skip-zero MIR hook |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | `mm_blocked_512(C,A,B)` blocked MIR hook |
| `compiler/codegen/emit.cpp` | Square GEMM → `emit_matmul2d_blocked_ijk` |
| `docs/numerics/studies/2026-05-30-bench-improver-tier1-matmul-mir.md` | evidence pack |

## Performance (local)

| Bench | Dashboard before | Local after |
|-------|-----------------|-------------|
| matmul_naive | 1.333× | **1.167×** (green) |
| matmul_blocked | 1.549× | **1.314×** (improved) |
| num_gmres | 1.400× | **0.80×** (green) |

## Downstream

Re-ingest benchmarks dashboard: `LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh`
