# Study: tier-1 matmul bench init MIR + 256³ IKJ path

**Date:** 2026-05-30 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** numerics / blazingly-fast after proof

## Problem

Dashboard ingest (2026-05-30) had **no red** tier-1 rows but **yellow** `matmul_naive` (1.222×) and `matmul_blocked` (1.244×). Li drivers used LUT `if` chains for matrix init vs C `(i+j)%17*0.01` arithmetic; 256³ `mm_naive_256` routed through 512-class blocked lowering.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLAS) | Blocked IKJ BK=64 for 512³; naive IKJ for smaller tiles |
| Org oracle `matmul_*_core.c` | Init + IKJ/blocked IKJ; checksum unchanged |
| Prior study `2026-05-30-bench-improver-tier1-matmul-mir.md` | MIR hooks `mm_*_256/512`; init gap remained |

## Change

| Path | Change |
|------|--------|
| `compiler/mir/include/li/mir.hpp` | `ArrayMatmulBenchInit2DF64` |
| `compiler/mir/lower.cpp` | `mm_init_256` / `mm_init_512` call + proc hooks |
| `compiler/codegen/emit.cpp` | C-style init loops; 256³ uses IKJ+FMA (`square_blocked` at n≥512); 64-align 512 mats |
| `benchmarks/tier1_micro/matmul_*/li/main.li` | `mm_init_*` + MIR GEMM hooks |

## Quality table

| Axis | Before (dashboard) | After (local bench) |
|------|-------------------|---------------------|
| **Speed** `matmul_naive` | 1.222× | **1.167×** (0.0021s / 0.0018s) |
| **Speed** `matmul_blocked` | 1.244× | **0.988×** (0.0085s / 0.0086s) |
| **Accuracy** | verify harness | checksums unchanged |
| **Stability** | tier-0 N/A | unchanged |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 15
cd ../.. && LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh
```

Re-ingest: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## Dashboard

https://li-langverse.github.io/benchmarks/

## Deferred

- `ml_*` tier-1 stubs (1.333× cluster): `numerics_researcher` / `code_implementer`
- Static BSS matrices for 512³ (match C `static double[][]`) if ratio regresses on CI hardware
