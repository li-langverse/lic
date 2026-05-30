# Study: tier-1 matmul — skip-zero assignment + 8-wide FMA (N≤256)

**Date:** 2026-05-30 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** numerics / blazingly-fast after proof

## Problem

Dashboard ingest (2026-05-30) showed **yellow** tier-1 rows: `matmul_naive` **1.222×** cpp, `matmul_blocked` **1.244×** (no red). Pure-Li drivers pre-zero `C` then assign `C = A @ B`; codegen was re-zeroing `C` inside `ArrayMatMul2DF64` and using 4-wide SIMD only.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLAS) | IKJ + register/cache blocking; oracle `matmul_blocked_core.c` uses BK=64 |
| LLVM `llvm.fmuladd` | Fused multiply-add on `@` lowering (`emit.cpp`) |
| Org oracle `common/matmul_core.c` | Scalar IKJ; checksum unchanged |
| Prior `2026-05-29-bench-improver-tier1-matmul.md` | `@` lowering was the missing step for naive |

## Change

| Path | Change |
|------|--------|
| `compiler/mir/lower.cpp` | `push_matmul2d` helper; `C = A @ B` assignment sets `use_loaded_int` (skip zero pass) |
| `compiler/codegen/emit.cpp` | 8-wide vector FMA on inner `j` when `n ≤ 256` and `n % 8 == 0` |

## Quality table

| Axis | Before (dashboard) | After (local bench, this host) |
|------|-------------------|--------------------------------|
| **Speed** `matmul_naive` | **1.222×** | **1.056×** (0.0019s / 0.0018s) — green |
| **Speed** `matmul_blocked` | **1.244×** | **~1.45×** (0.0125s / 0.0086s) — yellow; stack alloca vs C static BSS |
| **Accuracy** | verify harness | `matmul_naive verify ok`, `matmul_blocked verify ok` |
| **Stability** | tier-0 N/A | unchanged |

## Commands

```bash
cd lic && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 15
cd ../.. && ./scripts/check-tier1-li-vs-cpp.sh
```

Re-ingest after merge: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## Dashboard

https://li-langverse.github.io/benchmarks/ — refresh via normal ingest (no manual `summary.json` edits).
