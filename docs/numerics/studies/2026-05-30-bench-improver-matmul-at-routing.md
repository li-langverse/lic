# bench_improver: 512³ `@` blocked routing + skip-zero (PH-7e)

**Date:** 2026-05-30  
**north_star_fit:** blazingly-fast — PH-5b, PH-7e tier-1 pure-Li matmul  
**Status:** partial — `matmul_naive` green locally; `matmul_blocked` improved but advisory gap remains

## Problem

Public dashboard (2026-05-29 ingest) red rows in **lic**:

| Benchmark | ratio_vs_cpp | Root cause |
|-----------|--------------|------------|
| matmul_blocked | 1.549× | `C = A @ B` lowered to naive IKJ, not blocked BK=64 |
| matmul_naive | 1.333× | Redundant 256² zero-init inside codegen |
| num_gmres | 1.400× | Stale ingest (shared-C kernel; local 1.0×) |

## SOTA / Learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (2008) | Cache-blocked IKJ GEMM; BK=64 matches org oracle |
| `matmul_blocked_core.c` | 512³ blocked IKJ; C pre-zeros then accumulates |
| BLIS micro-kernel pattern | Inner `j` FMA on B row; Li uses 4-wide `llvm.fmuladd` on blocked path |
| LLVM autovec on scalar IKJ | Naive 256³ faster with scalar inner `j` + skip-zero vs manual vec4 |

## Quality table

| Axis | matmul_naive | matmul_blocked | num_gmres |
|------|--------------|----------------|-----------|
| **Speed (dashboard before)** | 1.333× | 1.549× | 1.400× |
| **Speed (local after, 10-run)** | **1.056×** | **1.287×** (best 1.216×) | **1.000×** |
| **Accuracy** | verify ok | verify ok | verify ok (shared C) |
| **Stability** | N/A tier-1 | N/A tier-1 | unchanged |

## Changes

| Path | Change |
|------|--------|
| `compiler/mir/lower.cpp` | Route 512³ `C = A @ B` → `ArrayMatMulBlocked2DF64`; 256³ assign sets `skip_zero` |
| `compiler/codegen/emit.cpp` | Blocked path honors `skip_zero`; naive 256³ uses scalar inner `j` (LLVM autovec) |

## Commands

```bash
cd lic && ./scripts/build.sh
python3 benchmarks/harness/bench.py --tier 1 --runs 10 --only matmul_naive,matmul_blocked,num_gmres
./scripts/check-tier1-li-vs-cpp.sh

cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Before / after CSV (local agent, `latest.csv`)

| benchmark | lang | wall_time before (dashboard) | wall_time after (local) | ratio after |
|-----------|------|------------------------------|-------------------------|-------------|
| matmul_naive | li | 0.0036 s | 0.0019 s | 1.056× |
| matmul_naive | cpp | 0.0027 s | 0.0018 s | — |
| matmul_blocked | li | 0.0158 s | 0.0112 s | 1.287× |
| matmul_blocked | cpp | 0.0102 s | 0.0087 s | — |
| num_gmres | li | 0.0007 s | 0.0004 s | 1.000× |
| num_gmres | cpp | 0.0005 s | 0.0004 s | — |

## Deferred

- **matmul_blocked** ~1.22–1.29× locally — needs outlined micro-kernel or static buffer parity with C `static` arrays (human review).
- **ml_*** (1.333×) — **li-math** family template; out of lic scope.
- **Yellow tier-2:** `md_thermostat_berendsen`, `md_thermostat_nose_hoover`.
