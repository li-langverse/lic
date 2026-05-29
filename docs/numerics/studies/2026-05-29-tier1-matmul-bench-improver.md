# Tier-1 matmul bench improver (2026-05-29)

## Problem

Public dashboard (`summary.json`, 2026-05-29T07:01Z) flagged **red** tier-1 rows:

| Benchmark | Ratio vs cpp | Path |
|-----------|--------------|------|
| `matmul_blocked` | 1.549× | `benchmarks/tier1_micro/matmul_blocked` |
| `matmul_naive` | 1.333× | `benchmarks/tier1_micro/matmul_naive` |

C++ blocked kernel keeps `512×512` matrices in **static BSS** (`matmul_blocked_core.c`); Li used ~6 MiB **stack** allocas plus `mm_blocked_512` MIR (blocked IKJ + f64×4 on `j`).

## SOTA / learned from

1. **BLIS / Goto & van de Geijn** — cache-blocked IKJ micro-kernels; Li mirrors `BK=64` tile structure.
2. **Org oracle** — `benchmarks/tier1_micro/matmul_*/common/*_core.c` shared with cpp/rust/julia.
3. **LLVM** — `llvm.fmuladd` on scalar IKJ inner loops; fixed-width vector loads on `j` when `n % 4 == 0`.

## Quality table

| Axis | Before (dashboard) | After (local `bench.py --tier 1 --runs 5`) |
|------|-------------------|---------------------------------------------|
| **Speed** `matmul_naive` | 1.333× | **1.000×** (li=0.0019s, cpp=0.0019s) |
| **Speed** `matmul_blocked` | 1.549× | **1.258×** (li=0.0112s, cpp=0.0089s) — still above 1.2× cap |
| **Stability** | verify ok | unchanged — checksum vs iterative reference |
| **Accuracy** | ulp noise only | unchanged |

## Implementation

- `compiler/codegen/emit.cpp`: `ArraySlot` uses `base` + `layout_ty`; `512×512` float matrices allocate as **internal BSS globals** (parity with C static buffers).
- No change to C++ oracle kernels or `threshold_ratio_cpp`.

## Commands

```bash
cd lic && ./scripts/build.sh
python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 5
LI_TIER1_PERF_STRICT=0 ./scripts/check-tier1-li-vs-cpp.sh
# Full dashboard refresh (CI or full local tier-1 run + ingest):
# cd benchmarks && LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh
```

## Deferred (PH-7e)

- `matmul_blocked` ≤1.2×: inner `64³` tile full unroll or wider SIMD (AVX-256), after Lean/contract review for parallel/simd.
- `num_gmres`, `ml_*` (li-math package) — separate owners.
- Tier-2 yellow: `md_thermostat_*` (~1.29×) — shared-kernel / physics path.

## North star

**Domain:** numerics / PH-5b (tier-1 micro), PH-7e (math→SIMD lowering). Proof-before-perf: no harness threshold edits.
