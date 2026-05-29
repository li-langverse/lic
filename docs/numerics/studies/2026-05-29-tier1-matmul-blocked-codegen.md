# Tier-1 matmul_blocked codegen (bench_improver)

**Date:** 2026-05-29  
**North star:** PH-5b blazingly-fast · PH-7e math→SIMD lowering  
**Benchmarks:** `matmul_blocked`, `matmul_naive` (harness unchanged for naive IKJ loops)

## Problem

Dashboard red rows (ingest `summary.json`): `matmul_blocked` **1.549×** cpp, `matmul_naive` **1.333×** cpp (tier-1 advisory cap **1.2×**).

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| BLIS / Goto & van de Geijn blocked GEMM | IKJ micro-kernel inside cache blocks; BK=64 for 512³ |
| LLVM `llvm.fmuladd` | Contract FMA on rank-1 updates |
| Org oracle `matmul_blocked_core.c` | ii–kk–jj tiles, `aik` hoisted, `c[i][j] += aik * b[k][j]` |
| Li `mm_blocked_512` MIR hook (7e-b) | Pure-Li hot path without `LI_EXTRA_C` |

## Quality table

| Axis | Before (dashboard) | After (local `bench.py` 5 runs) |
|------|-------------------|----------------------------------|
| **Speed** `matmul_blocked` | 1.549× cpp | **1.193×** cpp (≤1.2×) |
| **Speed** `matmul_naive` | 1.333× cpp | **1.053×** cpp (manual IKJ; unchanged driver) |
| **Accuracy** | verify ok | verify ok (checksum `1288460.7563999966` / `161055.1865999999`) |
| **Stability** | tier-0 N/A | N/A (tier-1 micro) |

## Commands

```bash
cd lic
./scripts/build.sh
python3 benchmarks/harness/bench.py --tier 1 --runs 5 --only matmul_naive,matmul_blocked
./scripts/check-tier1-li-vs-cpp.sh
```

Ingest (human/CI): `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## Code changes

- `compiler/codegen/emit.cpp`: vector FMA on blocked/IKJ inner `j`; 512×BK=64 constant tile schedule; `kUnrollMax=64`; optional `mm_naive_256` stub + IKJ SIMD helper (bench keeps explicit loops).
- `compiler/mir/lower.cpp`: `mm_naive_256` → `ArrayMatMul2DF64` hook (reserved for future drivers).

## Deferred (not this PR)

- `num_gmres` (1.4×) — shared C kernel; needs pure-Li Krylov or slimmer FFI.
- `ml_*` (1.333×) — **li-math** package, not lic harness alone.
- Yellow tier-2 thermostats — micro-opt separate pass.
