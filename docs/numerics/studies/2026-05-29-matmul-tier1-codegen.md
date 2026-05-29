# Study: tier-1 pure-Li matmul codegen (2026-05-29)

## Problem

Dashboard red rows (ingested `summary.json`, 2026-05-29): `matmul_naive` (1.33× cpp), `matmul_blocked` (1.55× cpp). Both are pure-Li tier-1 micro kernels (PH-5b, PH-7e).

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| BLIS / Goto & van de Geijn blocked GEMM | IKJ + cache blocking (`BK=64`) for `matmul_blocked` |
| LLVM `llvm.fmuladd` | Contracted multiply-add for non–numerically-stable fast paths |
| Org oracle `benchmarks/tier1_micro/*/common/*_core.c` | Init formulas and IKJ/blocked structure must match for verify |
| Existing `mm_blocked_512` MIR hook (lic #148 / PH-7e) | Named proc → `ArrayMatMulBlocked2DF64` in codegen |

## Changes (lic)

1. **`mm_naive_256` MIR hook** — mirrors `mm_blocked_512`; lowers to `ArrayMatMul2DF64` with FMA + f64×4 `j` SIMD.
2. **Codegen init for blocked** — `emit_matmul2d_init_abc` in LLVM (matches C `% 17` / `% 13` init); `matmul_blocked/li/main.li` calls only the hook + checksum.
3. **Vector FMA** — `vfma` on 4-wide stores in blocked + naive loop emitters; 8-wide `j` step in blocked tiles.
4. **`matmul_naive/li/main.li`** — LUT init (no bare `cast[float]`); GEMM via `mm_naive_256`.

## Quality table

| Axis | matmul_naive | matmul_blocked |
|------|--------------|----------------|
| Stability | unchanged (same checksum vs iterative) | unchanged |
| Accuracy | verify ok, same ulps as before | verify ok |
| Speed (local advisory) | **1.167×** cpp (≤1.2×) | **1.264×** cpp (was ~1.27–1.55× ingested; still gap) |
| Memory | stack 2D arrays (unchanged) | stack 2D arrays (unchanged) |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive --runs 5
python3 bench.py --tier 1 --only matmul_blocked --runs 5
cd ../.. && ./scripts/check-tier1-li-vs-cpp.sh
```

Ingest (human/CI): `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## North star

PH-5b (blazingly-fast numerics), PH-7e (math→SIMD lowering). Proof-before-perf: no `trusted.lean` or parallel codegen changes.
