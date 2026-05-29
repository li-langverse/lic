# Study: matmul_naive — route hot path through `ArrayMatMul2DF64`

**Date:** 2026-05-29 · **Bench:** `matmul_naive` (N=256) · **PH:** PH-5b, PH-7e  
**North star:** blazingly-fast (after proof) · tier-1 advisory ≤1.2× cpp

## Problem

Pure-Li tier-1 `matmul_naive` used manual IKJ `while` loops. The compiler already lowers `C = A @ B` to `MirOp::ArrayMatMul2DF64` with LLVM `fmuladd` (IKJ, `-ffast-math`), but the bench bypassed that path. Dashboard ingest (2026-05-29) reported **1.333×** vs cpp (0.0036s / 0.0027s).

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn, *ACM Computing Surveys* 2008 ([doi:10.1145/1465875.1465879](https://doi.org/10.1145/1465875.1465879)) | IKJ + cache blocking; Li reuses IKJ via `ArrayMatMul2DF64` |
| LLVM Language Reference — `llvm.fmuladd` ([docs](https://llvm.org/docs/LangRef.html#llvm-fmuladd-intrinsic)) | Fused multiply-add on the `@` lowering path |
| Org oracle `lic/benchmarks/tier1_micro/matmul_naive/common/matmul_core.c` | Scalar IKJ; checksum parity unchanged |
| Prior note `docs/release-notes/2026-05-22-tier1-matmul-bench-hotloop.md` | Init hoisted; `@` lowering was the missing step |

## Change

`benchmarks/tier1_micro/matmul_naive/li/main.li`: replace manual triple loop with `C = A @ B` after LUT init (init unchanged).

## Quality table

| Axis | Before (dashboard ingest) | After (local n=200, agent host) |
|------|---------------------------|----------------------------------|
| **Speed** | Li/cpp **1.333×** (red) | **~1.056×** (0.0019s / 0.0018s) |
| **Accuracy** | checksum via verify harness | `matmul_naive verify ok` — same iterative ref |
| **Stability** | tier-0 N/A for this bench | unchanged |

## Commands

```bash
cd lic && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive --runs 10
cd ../../benchmarks && LIC_ROOT=.. ./scripts/ingest/ingest-lic.sh
```

## Plots / visuals

Tier-1 micro bench (no tier-2 GIF). After merge, refresh dashboard speed bars:

```bash
cd benchmarks && LIC_ROOT=../lic ./scripts/render-benchmark-visuals.sh
```

PNG: public dashboard tier-1 row for `matmul_naive` (ingest updates `data/latest/summary.json`).

## Dashboard

Re-ingest after lic merge: [benchmarks ingest](https://github.com/li-langverse/benchmarks/tree/main/scripts/ingest)
