# Study: matmul_naive — route hot path through `ArrayMatMul2DF64`

**Date:** 2026-05-29 · **Bench:** `matmul_naive` (N=256) · **PH:** PH-5b, PH-7e

## Problem

Pure-Li tier-1 `matmul_naive` used manual IKJ `while` loops. The compiler already lowers `C = A @ B` to `MirOp::ArrayMatMul2DF64` with LLVM `fmuladd` (IKJ, `-ffast-math`), but the bench bypassed that path.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| BLAS reference (Goto & van de Geijn) | IKJ + register blocking; we reuse IKJ via codegen |
| LLVM `llvm.fmuladd` | Fused multiply-add on the `@` lowering path |
| Org oracle `common/matmul_core.c` | Scalar IKJ; checksum parity unchanged |
| Prior note `2026-05-22-tier1-matmul-bench-hotloop.md` | Init hoisted; `@` lowering was the missing step |

## Change

`benchmarks/tier1_micro/matmul_naive/li/main.li`: replace manual triple loop with `C = A @ B` after LUT init (init unchanged).

## Quality table

| Axis | Before (dashboard ingest) | After (local n=200, this host) |
|------|---------------------------|--------------------------------|
| **Speed** | Li/cpp **1.333×** (0.0036s / 0.0027s) | **~1.05×** (0.0020s / 0.0019s) |
| **Accuracy** | checksum via verify harness | `matmul_naive verify ok` — same iterative ref |
| **Stability** | tier-0 N/A for this bench | unchanged |

## Commands

```bash
cd lic && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive --runs 10
```

## Dashboard

Re-ingest after lic merge: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`
