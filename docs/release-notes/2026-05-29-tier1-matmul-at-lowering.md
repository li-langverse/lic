# Tier-1 matmul: use `@` lowering for pure-Li hot path

## Summary

`matmul_naive` and `matmul_blocked` Li drivers now call `C = A @ B` after matrix init so the hot path uses `ArrayMatMul2DF64` (LLVM FMA IKJ) instead of scalar `while` loops or the no-op `mm_blocked_512` stub.

## Performance

| Bench | Dashboard ratio (before) | Local ratio (after, advisory) |
|-------|---------------------------|-------------------------------|
| `matmul_naive` | 1.333× | ~1.05× |
| `matmul_blocked` | 1.549× | ~1.30× (still needs blocked codegen) |

## Agent continuation

1. Merge and run benchmarks ingest.
2. Implement cache-blocked `ArrayMatMul2DF64` for N≥512 (**7e**, no hand-written Li IKJ).
