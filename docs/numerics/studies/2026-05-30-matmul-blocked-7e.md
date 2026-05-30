# PH-7e tier-1 matmul blocked codegen study

**Date:** 2026-05-30  
**north_star_fit:** blazingly-fast (PH-5b, PH-7e) — pure-Li `@` blocked IKJ for 512³ matmul  
**Status:** tier-1 cap met locally (10-run median) — ingest pending merge + full suite

## Problem

`matmul_blocked` (512×512, BK=64 IKJ tiles) was **red** at **1.549×** cpp on the public dashboard; `matmul_naive` at **1.333×**. C++ oracle uses cache-blocked GEMM (`common/matmul_blocked_core.c`); Li codegen used scalar-gather SIMD on stack allocas without 32-byte alignment.

## SOTA / Learned from

| Source | Takeaway |
|--------|----------|
| BLIS / Goto & van de Geijn (2008) | IKJ micro-kernel inside L1/L2 tiles; BK≈64 for f64 |
| `matmul_blocked_core.c` (org oracle) | 512³ blocked IKJ, BK=64, `aik` hoisted inner loop |
| LLVM `llvm.fmuladd` + 4-wide `j` | Vector FMA on inner dimension when tile aligns |

## Quality table

| Axis | Before (dashboard) | After (local 10-run median) | Evidence |
|------|-------------------|-----------------------------|----------|
| Speed `matmul_naive` | 1.333× cpp | **0.947×** (li=0.0018s, cpp=0.0019s) | `lic/benchmarks/results/latest.csv` (10-run median) |
| Speed `matmul_blocked` | 1.549× cpp | **1.000×** (li=0.0088s, cpp=0.0088s) | same |
| Accuracy | pass | pass (checksums unchanged) | `bench.py --tier 1` verify |
| Stability | N/A tier-1 | unchanged | — |

## Implementation

1. **MIR:** `push_matmul2d_mir` routes 512³ `@` → blocked IKJ (BK=64).
2. **Codegen:** `emit_matmul2d_blocked_ijk` — tiled IKJ; tile loops reset `kk`/`jj` per tile row (correctness fix, merged earlier).
3. **Codegen (pass 1):** 4-wide inner-`j` SIMD (`gather_matrow_f64x4` / `scatter_matrow_f64x4`, vector `llvm.fmuladd`) in blocked and flat IKJ paths.
4. **Codegen (pass 2):** 32-byte `ArrayAlloc` alignment for ≥128² matrices; contiguous `llvm.load`/`store` `<4 x f64>` on aligned tiles (fallback scalar gather otherwise); SIMD inner-`j` when `n >= 64`.
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

- Dashboard ingest: run full `./scripts/run-full-benchmark-suite.sh` on CI after merge — partial `--only` ingest clears unrelated rows.
- `num_gmres` (1.4× dashboard) — shared-C wrapper; **1.0×** locally (li=cpp=0.0005s); stale dashboard row.
- `ml_conv2d_forward`, `ml_mlp_*` (1.333×) — **li-math** repo (PH-ML Wave 2), not lic codegen.
- `md_thermostat_*` (yellow ~1.29×) — tier-2 shared kernel; micro-opt deferred.
