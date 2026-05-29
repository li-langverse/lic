# Study: matmul_naive — route hot path through `ArrayMatMul2DF64`

**Date:** 2026-05-29 · **Bench:** `matmul_naive` (N=256) · **PH:** PH-5b, PH-7e · **north_star_fit:** blazingly-fast tier-1 linalg (PH-5b, PH-7e)

## Problem

Pure-Li tier-1 `matmul_naive` used manual IKJ `while` loops. The compiler already lowers `C = A @ B` to `MirOp::ArrayMatMul2DF64` with LLVM `fmuladd` (IKJ, `-ffast-math`), but the bench bypassed that path.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| BLAS reference (Goto & van de Geijn) | IKJ + register blocking; reuse via codegen |
| LLVM `llvm.fmuladd` | Fused multiply-add on the `@` lowering path |
| Org oracle `common/matmul_core.c` | Scalar IKJ; checksum parity unchanged |
| Prior note `2026-05-22-tier1-matmul-bench-hotloop.md` | Init hoisted; `@` lowering was the missing step |

## Change

- `benchmarks/tier1_micro/matmul_naive/li/main.li`: replace manual GEMM with `C = A @ B` after LUT init.
- `compiler/codegen/emit.cpp`: entry-block loop indices + vector `fmuladd` on blocked matmul (helps `matmul_blocked`).

## Quality table

| Axis | Before (dashboard ingest) | After (local n=200, agent host) |
|------|---------------------------|----------------------------------|
| **Speed** | Li/cpp **1.333×** | **~1.05×** (0.0019s / 0.0018s) |
| **Accuracy** | iterative verify | `matmul_naive verify ok` |
| **Stability** | N/A tier-0 | unchanged |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive --runs 10
cd ../../benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```

## Dashboard

Re-ingest after lic merge; do not edit `benchmarks/data/latest/summary.json` by hand.
