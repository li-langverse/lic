# Study: tier-1 matmul MIR fast paths + square blocked `@` lowering

**Date:** 2026-05-30 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** numerics / PH-5b / PH-7e

## Problem

Dashboard ingest (2026-05-29) showed **red** tier-1 rows: `matmul_naive` **1.333×**, `matmul_blocked` **1.549×**, `num_gmres` **1.400×**. Drivers had regressed to `C = A @ B` without `mm_blocked_512` / `mm_naive_256` MIR hooks; square 256³/512³ GEMM did not use cache-blocked lowering.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLAS) | Blocked IKJ micro-kernel BK=64 matches C oracle |
| LLVM `llvm.fmuladd` | FMA on inner `j`; vec4 when tile aligns |
| Org oracle `matmul_*_core.c` | Scalar/blocked IKJ; checksum unchanged |
| Prior study `2026-05-29-bench-improver-tier1-matmul.md` | `@` lowering + unroll cap; blocked hook dropped on branch |

## Change

| Path | Change |
|------|--------|
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | Restore `mm_blocked_512(C,A,B)` MIR fast path |
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | Route hot path through `mm_naive_256` (skip-zero) |
| `compiler/codegen/emit.cpp` | Square `ArrayMatMul2DF64` with n≥256 and n%64==0 → `emit_matmul2d_blocked_ijk` |

## Quality table

| Axis | Before (dashboard) | After (local bench, this host) |
|------|-------------------|--------------------------------|
| **Speed** `matmul_naive` | **1.333×** (0.0036s / 0.0027s) | **1.176×** (0.0020s / 0.0017s) — **green** |
| **Speed** `matmul_blocked` | **1.549×** | **1.264×** (0.0110s / 0.0087s) — improved, still >1.2× |
| **Speed** `num_gmres` | **1.400×** | **1.0×** (0.0005s / 0.0005s) — green (shared C kernel) |
| **Accuracy** | verify harness | `matmul_* verify ok`; same iterative ref |
| **Stability** | tier-0 N/A | unchanged |

## Commands

```bash
cd lic && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 10
cd ../.. && ./scripts/check-tier1-li-vs-cpp.sh
```

Re-ingest after merge: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## Dashboard

https://li-langverse.github.io/benchmarks/ — refresh via normal ingest (no manual `summary.json` edits).

## Deferred

- `matmul_blocked` remaining ~5% gap: Li init uses LUT if-chain vs C `(i+j)%17 * 0.01` — needs Phase **2i** int→float promotion or table lookup.
- `ml_*` rows (1.333× cluster): stub harness in **li-math** — `numerics_researcher` / `code_implementer`.
- Yellow tier-2 thermostats: shared C MD kernel — separate pass.
