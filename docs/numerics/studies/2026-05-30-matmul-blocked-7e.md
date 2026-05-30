# PH-7e tier-1 matmul blocked codegen study

**Date:** 2026-05-30  
**north_star_fit:** blazingly-fast (PH-5b, PH-7e) — pure-Li `@` blocked IKJ for 512³ matmul  
**Status:** partial — `matmul_naive` at cap; `matmul_blocked` improved but still >1.2× locally

## Problem

`matmul_blocked` (512×512, BK=64 IKJ tiles) was **red** at **1.549×** cpp on the public dashboard; `matmul_naive` at **1.333×**. C++ oracle uses cache-blocked GEMM (`common/matmul_blocked_core.c`); Li codegen lacked 4-wide inner-`j` vector FMA.

## SOTA / Learned from

| Source | Takeaway |
|--------|----------|
| BLIS / Goto & van de Geijn (2008) | IKJ micro-kernel inside L1/L2 tiles; BK≈64 for f64 |
| `matmul_blocked_core.c` (org oracle) | 512³ blocked IKJ, BK=64, `aik` hoisted inner loop |
| LLVM `llvm.fmuladd` + 4-wide `j` | Vector FMA on inner dimension when tile aligns |

## Quality table

| Axis | Before (dashboard) | After (local 10-run median) | Evidence |
|------|-------------------|-----------------------------|----------|
| Speed `matmul_naive` | 1.333× cpp | **0.95–1.21×** (median ~1.0×) | `lic/benchmarks/results/latest.csv` |
| Speed `matmul_blocked` | 1.549× cpp | **1.26–1.31×** (was 1.62× pre-SIMD) | same |
| Accuracy | pass | pass (checksums unchanged) | `bench.py --tier 1` verify |
| Stability | N/A tier-1 | unchanged | — |

## Implementation

1. **MIR:** `push_matmul2d_mir` routes 512³ `@` → blocked IKJ (BK=64).
2. **Codegen:** `emit_matmul2d_blocked_ijk` — tiled IKJ; tile loops reset `kk`/`jj` per tile row (correctness fix, merged earlier).
3. **Codegen (this pass):** 4-wide inner-`j` SIMD (`gather_matrow_f64x4` / `scatter_matrow_f64x4`, vector `llvm.fmuladd`) in blocked and flat IKJ paths; SIMD gated for `n >= 128`.
4. **Bench driver:** `matmul_blocked/li/main.li` uses `C = A @ B` (pure Li).

## Commands

```bash
cd lic && ./scripts/build.sh
cd lic/benchmarks/harness && python3 bench.py --tier 1 --runs 10 --only matmul_blocked,matmul_naive
cd lic && ./scripts/check-tier1-li-vs-cpp.sh

cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Remaining gaps

- `matmul_blocked` **~1.31×** locally (target ≤1.2×) — micro-kernel register blocking / `mm_lut_*` init overhead vs C arithmetic init.
- `num_gmres` (1.4× dashboard) — shared-C wrapper; green locally on this machine.
- `ml_*` (1.333×) — **li-math** repo, out of lic scope.
