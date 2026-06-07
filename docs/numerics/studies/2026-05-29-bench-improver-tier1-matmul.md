# Study: tier-1 matmul_naive — route GEMM through `ArrayMatMul2DF64`

**Date:** 2026-05-29 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** numerics / PH-5b / PH-7e

## Problem

Dashboard ingest (2026-05-29) showed **red** tier-1 rows: `matmul_naive` **1.333×** cpp, `matmul_blocked` **1.549×**, `num_gmres` **1.400×**. Pure-Li `matmul_naive` used manual IKJ `while` loops that LLVM lowered without `llvm.fmuladd`, bypassing the existing `@` → `ArrayMatMul2DF64` MIR path.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLAS) | IKJ + register reuse; codegen already implements IKJ |
| LLVM `llvm.fmuladd` | Fused multiply-add on `@` lowering (`emit.cpp`) |
| Org oracle `common/matmul_core.c` | Scalar IKJ; checksum unchanged |
| Prior note `2026-05-22-tier1-matmul-bench-hotloop.md` | Init hoisted; `@` lowering was the missing step |

## Change

| Path | Change |
|------|--------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | Replace manual IKJ triple loop with `C = A @ B` after LUT init |
| `compiler/codegen/emit.cpp` | Raise `ArrayMatMul2DF64` unroll cap to **64³** (matches release note) |

## Quality table

| Axis | Before (dashboard) | After (local bench, this host) |
|------|-------------------|--------------------------------|
| **Speed** `matmul_naive` | Li/cpp **1.333×** (0.0036s / 0.0027s) | **~1.06×** (0.0019s / 0.0018s, n=200) |
| **Speed** `matmul_blocked` | **1.549×** | **~1.24×** (0.0109s / 0.0088s) — still red; needs MIR/codegen follow-up |
| **Speed** `num_gmres` | **1.400×** | **~1.0×** (0.0005s / 0.0005s) — green locally; shared C kernel |
| **Accuracy** | verify harness | `matmul_naive verify ok` — same iterative ref |
| **Stability** | tier-0 N/A | unchanged |

## Commands

```bash
cd lic && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 10
./scripts/check-tier1-li-vs-cpp.sh
```

Re-ingest after merge: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## Dashboard

https://li-langverse.github.io/benchmarks/ — refresh via normal ingest (no manual `summary.json` edits).
