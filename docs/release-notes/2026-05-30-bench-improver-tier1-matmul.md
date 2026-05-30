# Bench improver: tier-1 matmul_naive `@` + blocked VFMA codegen

## Summary

Routes `matmul_naive` through `C = A @ B` (`ArrayMatMul2DF64` IKJ + FMA). Speeds blocked 512³ matmul via vector `llvm.fmuladd` in `emit_matmul2d_blocked_ijk` and raises matmul unroll threshold to 64³.

## Changed

| Path | Evidence |
|------|----------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | `C = A @ B` after LUT init |
| `compiler/codegen/emit.cpp` | VFMA vector tile; `kUnrollMax=64` |
| `docs/numerics/studies/2026-05-30-bench-improver-tier1-red-rows.md` | before/after CSV + commands |

## Performance

Local tier-1 (this host): `matmul_naive` **1.056×** cpp; `matmul_blocked` **1.233×** cpp (improved from dashboard 1.549×; advisory gap remains); `num_gmres` **1.000×** (shared C).

## Downstream

Run `benchmarks` ingest after merge.
