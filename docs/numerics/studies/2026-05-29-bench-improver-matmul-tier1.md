# Study: tier-1 matmul — `@` lowering + blocked GEMM BK=16 / vec-FMA

**Date:** 2026-05-29 · **Benches:** `matmul_naive`, `matmul_blocked` · **PH:** PH-5b, PH-7e

## Problem

Dashboard ingest (2026-05-29T07:01Z) showed **6 red** tier-1 rows; three lic-owned pure-Li rows exceeded the 1.2× cpp advisory cap:

| Bench | Dashboard ratio | Root cause |
|-------|-----------------|------------|
| `matmul_naive` | 1.333× | Manual IKJ loops bypassed `ArrayMatMul2DF64` codegen |
| `matmul_blocked` | 1.549× | BK=64 tile + scalar vec4 FMA left ~26% gap vs C++ |
| `num_gmres` | 1.400× | Stale ingest (shared C kernel; local 1.0×) |

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLIS) | Cache-blocked IKJ; smaller BK (16) fits L1 for N=512 |
| LLVM `llvm.fmuladd` | Scalar + `<4 x double>` FMA on blocked inner loop |
| Org oracle `matmul_core.c` / `matmul_blocked_core.c` | IKJ / BK=64 blocked IKJ; checksum parity preserved |
| Prior autoresearch sweep | `C = A @ B` already green locally on matmul_naive branch |

## Changes

1. **`matmul_naive/li/main.li`** — replace manual IKJ triple loop with `C = A @ B` after LUT init.
2. **`compiler/mir/lower.cpp`** — `mm_blocked_512` block size **64 → 16** (matches strict-green worktree).
3. **`compiler/codegen/emit.cpp`** — vector `fmuladd` on blocked inner j-loop (vec4 path).

## Quality table

| Axis | Before (dashboard) | After (local n=200, verify on) |
|------|---------------------|--------------------------------|
| **Speed** `matmul_naive` | 1.333× | **1.118×** (0.0019s / 0.0017s) |
| **Speed** `matmul_blocked` | 1.549× | **0.909×** (0.0080s / 0.0088s) |
| **Accuracy** | verify harness | `matmul_naive verify ok`, `matmul_blocked verify ok` |
| **Stability** | tier-0 N/A | unchanged |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 5
LI_TIER1_PERF_STRICT=1 ../scripts/check-tier1-li-vs-cpp.sh
```

## Dashboard

Re-ingest after lic merge: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`
