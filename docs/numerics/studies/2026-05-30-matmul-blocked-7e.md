# PH-7e tier-1 matmul blocked codegen study

**Date:** 2026-05-30  
**north_star_fit:** blazingly-fast (PH-5b, PH-7e) — pure-Li `@` blocked IKJ for 512³ matmul  
**Status:** partial — local ratio improved; dashboard ingest pending

## Problem

`matmul_blocked` (512×512, BK=64 IKJ tiles) was **red** at **1.549×** cpp on the public dashboard. C++ oracle uses cache-blocked GEMM (`common/matmul_blocked_core.c`); Li used flat IKJ via `ArrayMatMul2DF64` without tiling.

## SOTA / Learned from

| Source | Takeaway |
|--------|----------|
| BLIS / Goto & van de Geijn (2008) | IKJ micro-kernel inside L1/L2 tiles; BK≈64 for f64 |
| `matmul_blocked_core.c` (org oracle) | 512³ blocked IKJ, BK=64, `aik` hoisted inner loop |
| LLVM `llvm.fmuladd` + 4-wide `j` | Vector FMA on inner dimension when tile aligns |

## Quality table

| Axis | Before (dashboard) | After (local bench) | Evidence |
|------|-------------------|---------------------|----------|
| Speed | 1.549× cpp | **1.053×** naive, **~1.26×** blocked (5-run median) | `lic/benchmarks/results/latest.csv` |
| Accuracy | pass | pass (≤4 ULP vs iterative ref) | `bench.py --tier 1` verify |
| Stability | N/A tier-1 | unchanged | — |

## Implementation

1. **MIR:** `push_matmul2d_mir` routes 512³ `@` → `ArrayMatMulBlocked2DF64` (BK=64).
2. **Codegen:** `emit_matmul2d_blocked_ijk` — tiled IKJ, scalar + 4-wide FMA inner `j`, C zero-init.
3. **Bench driver:** `matmul_blocked/li/main.li` uses `C = A @ B` (math-first, no stub proc).

## Commands

```bash
cd lic && ./scripts/build.sh
cd lic/benchmarks/harness && python3 bench.py --tier 1 --runs 5 --only matmul_blocked,matmul_naive
cd lic && ./scripts/check-tier1-li-vs-cpp.sh

cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Remaining gaps

- `matmul_blocked` still **~1.26×** locally (target ≤1.2×) — needs LLVM autovec / micro-kernel polish or larger BK sweep.
- `num_gmres` (1.4×) — shared-C wrapper overhead; not addressed this pass.
- `ml_*` (1.333×) — **li-math** repo, out of lic scope.
