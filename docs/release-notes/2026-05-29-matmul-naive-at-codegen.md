# Release notes: tier-1 `matmul_naive` via `@` lowering

**Date:** 2026-05-29 · **PH:** PH-5b, PH-7e

- Pure-Li `matmul_naive` hot path uses `C = A @ B` → `ArrayMatMul2DF64` with `llvm.fmuladd` (replaces manual `while` IKJ).
- Blocked matmul codegen: SIMD inner `j` loop uses vector `fmuladd` under fast-math (partial `matmul_blocked` win; still >1.2× vs C++ on reference host).
- Evidence: `docs/numerics/studies/2026-05-29-matmul-naive-at-codegen.md`, `./scripts/check-tier1-li-vs-cpp.sh`.
