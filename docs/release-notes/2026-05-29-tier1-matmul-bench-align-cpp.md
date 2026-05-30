# Tier-1 matmul benches: align Li drivers with C++ kernels

## Summary

`matmul_naive` and `matmul_blocked` Li drivers now mirror the C++ reference structure (LUT init + IKJ / cache-blocked IKJ) instead of repeated `C = A @ B` tiles. `ArrayMatMul2DF64` unrolls through **64├ù64** (was capped at 24 / 4096 flops).

## Agent continuation

1. **Build:** `./scripts/build.sh` (LLVM 18).
2. **Bench:** `python3 benchmarks/harness/bench.py --tier 1`; `./scripts/check-tier1-li-vs-cpp.sh`.
3. **Ingest:** in `benchmarks` repo ÔÇö `LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh`.

## Changed

| Path | Evidence |
|------|----------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | single 256┬│ IKJ (matches `matmul_core.c`) |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | 512├ù blocked 64┬│ BK=16 IKJ (matches blocked C pattern) |
| `compiler/codegen/emit.cpp` | unroll threshold 64┬│ for `ArrayMatMul2DF64` |

## Not changed

- C++ reference kernels (`matmul_core.c`, `matmul_blocked_core.c`).
- `num_gmres`, `li-math` ML rows (separate packages).

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A ÔÇö bench harness only |
| **Security** | N/A |
| **Performance** | Target Ôëñ1.2├ù C++ on tier-1 matmul rows after CSV refresh |
| **Downstream** | Re-run benchmarks dashboard ingest |
