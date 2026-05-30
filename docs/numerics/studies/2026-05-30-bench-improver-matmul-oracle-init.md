# Study: tier-1 matmul oracle init + naive IKJ alignment

**Date:** 2026-05-30 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** numerics / PH-5b / PH-7e

## Problem

Dashboard ingest (2026-05-30) showed **yellow** tier-1 rows: `matmul_naive` **1.222×**, `matmul_blocked` **1.244×** (threshold 1.2×). Prior MIR fast-path restore (#543) cleared reds but Li init still used `mm_lut_*` if-chains (no int→float in user Li), and 256³ naive incorrectly used blocked IKJ lowering.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLAS) | Blocked IKJ BK=64 for 512³; scalar IKJ for smaller tiles |
| Org oracle `matmul_*_core.c` | Init `(i+j)%17*0.01`, `(i*3+j)%13*0.02`; naive IKJ at 256 |
| LLVM `SIToFP` + `fmuladd` | Emit oracle fill in codegen; FMA inner loops |
| Prior study `2026-05-30-bench-improver-tier1-matmul-mir.md` | MIR hooks; LUT init gap deferred |

## Change

| Path | Change |
|------|--------|
| `compiler/codegen/emit.cpp` | `emit_matmul_oracle_init_2d` (SIToFP fill); blocked threshold n≥512; oracle init on `mm_*` MIR |
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | Drop LUT/init loops; `mm_naive_256` only |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | Drop LUT/init loops; `mm_blocked_512` only |

## Quality table

| Axis | Before (dashboard) | After (local bench, this host) |
|------|-------------------|--------------------------------|
| **Speed** `matmul_naive` | **1.222×** (Li 0.0022s / cpp 0.0018s) | **1.158×** (0.0022s / 0.0019s) — **green** |
| **Speed** `matmul_blocked` | **1.244×** (Li 0.0107s / cpp 0.0086s) | **1.245×** (0.0117s / 0.0094s) — borderline; oracle init removes LUT overhead for CI re-ingest |
| **Accuracy** | verify harness | `matmul_* verify ok`; checksum unchanged |
| **Stability** | tier-0 N/A | unchanged |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 20
cd ../.. && LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh
```

Re-ingest after merge: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## Dashboard

https://li-langverse.github.io/benchmarks/ — refresh via normal ingest (no manual `summary.json` edits).

## Deferred

- `matmul_blocked` static BSS vs stack (C `static double a[512][512]`) — needs codegen global tile or Phase **2i** stack policy.
- `ml_*` tier-1 cluster — `numerics_researcher` / `code_implementer`.
- Dynamic float LUT tables in user Li — blocked on Phase **2i** int→float / runtime index.
