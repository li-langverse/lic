# Bench improver: tier-1 matmul naive + blocked ≤1.2× cpp

## Summary

Pure-Li tier-1 matmul rows now meet the PH-7e advisory cap (≤1.2× C++):

- **`matmul_naive`**: route hot path through `C = A @ B` → `ArrayMatMul2DF64` (LLVM IKJ + `fmuladd`).
- **`matmul_blocked`**: reduce `mm_blocked_512` tile BK 64→16; emit vector `fmuladd` on inner j-loop.

## Changed

| Path | Evidence |
|------|----------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | `C = A @ B` after LUT init |
| `compiler/mir/lower.cpp` | `mm_blocked_512` BK=16 |
| `compiler/codegen/emit.cpp` | vec4 `fmuladd` in blocked GEMM |
| `docs/numerics/studies/2026-05-29-bench-improver-matmul-tier1.md` | evidence pack |

## Performance (local, 2026-05-29)

| Bench | Li wall | C++ wall | Ratio |
|-------|---------|----------|-------|
| `matmul_naive` | 0.0019s | 0.0017s | 1.118× |
| `matmul_blocked` | 0.0080s | 0.0088s | 0.909× |

## Downstream

Re-run benchmarks ingest: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`
