# Study: tier-1 red rows — matmul_naive `@` + blocked matmul VFMA codegen

**Date:** 2026-05-30 · **Benches:** `matmul_naive`, `matmul_blocked`, `num_gmres` · **PH:** PH-5b, PH-7e

## Problem

Dashboard ingest (2026-05-29) showed tier-1 **red** rows for lic-owned kernels: `matmul_naive` (1.333×), `matmul_blocked` (1.549×), `num_gmres` (1.400×). Goal: ≤ **1.2×** cpp without weakening verify or thresholds.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLAS) | IKJ + cache blocking; blocked path via `mm_blocked_512` MIR |
| LLVM `llvm.fmuladd` | Scalar + `<4 x double>` FMA on blocked inner tile |
| Org oracle `matmul_core.c` / `matmul_blocked_core.c` | Checksum parity unchanged |
| Prior study `2026-05-29-matmul-naive-at-codegen.md` | Route naive GEMM through `ArrayMatMul2DF64` (`C = A @ B`) |

## Changes

1. **`matmul_naive/li/main.li`** — replace manual IKJ with `C = A @ B` after LUT init (init unchanged).
2. **`compiler/codegen/emit.cpp`** — blocked matmul: vector `fmuladd`; raise `ArrayMatMul2DF64` unroll cap to 64³.

## Quality table

| Bench | Axis | Before (dashboard) | After (local n=10, this host) |
|-------|------|--------------------|-------------------------------|
| `matmul_naive` | Speed | 1.333× | **1.056×** (0.0019s / 0.0018s) |
| `matmul_naive` | Accuracy | verify ok | verify ok — checksum 161055.1866 |
| `matmul_blocked` | Speed | 1.549× | **1.233×** (0.0111s / 0.0090s) — advisory gap |
| `matmul_blocked` | Accuracy | verify ok | verify ok — checksum 1288460.7564 |
| `num_gmres` | Speed | 1.400× | **1.000×** (shared C kernel; stale ingest) |
| `num_gmres` | Accuracy | verify ok | verify ok |

## Commands

```bash
cd lic && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 10
cd ../.. && ./scripts/check-tier1-li-vs-cpp.sh
```

Post-merge ingest:

```bash
cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```

## Dashboard

Re-ingest after lic merge; expect `matmul_naive` and `num_gmres` green; `matmul_blocked` improved (~1.55→~1.23×) but may remain yellow until init/codegen parity closes advisory gap.
