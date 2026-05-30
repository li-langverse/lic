# Tier-1 matmul codegen — bench improver pass

**Date:** 2026-05-29  
**PH:** PH-5b, PH-7e  
**North star:** blazingly-fast (after proof) — tier-1 pure-Li matmul ≤1.2× C++

## Problem

Dashboard red rows (ingest `summary.json` 2026-05-29):

| Benchmark | ratio_vs_cpp (before) | Driver |
|-----------|----------------------:|--------|
| `matmul_blocked` | 1.549 | pure Li (`mm_blocked_512` MIR) |
| `matmul_naive` | 1.333 | pure Li (IKJ loops) |
| `num_gmres` | 1.400 | shared C kernel |
| `ml_*` (×3) | 1.333 | WP4 catalog smokes (stub) |

## SOTA / Learned from

1. **Goto & van de Geijn (2008)** — cache-blocked GEMM (IKJ micro-kernel inside tiles); Li `ArrayMatMulBlocked2DF64` mirrors 64×64 blocking.
2. **BLIS / OpenBLIS** — FMA accumulation in inner dimension; codegen emits `llvm.fmuladd` scalar + 4-wide vector.
3. **LLVM loop vectorizer docs** — explicit `<4 x double>` inner-`j` step when `N % 4 == 0` beats scalar autovec on stack `[N][N]` layouts for 512³.
4. **Org oracle** — `benchmarks/tier1_micro/matmul_blocked/common/matmul_blocked_core.c` (unchanged); checksum parity preserved.

## Changes

| Path | Change |
|------|--------|
| `compiler/codegen/emit.cpp` | Vector `fmuladd` on blocked inner `j`; IKJ loop path vector FMA for `ArrayMatMul2DF64` |
| `compiler/mir/lower.cpp` | `mm_naive_256` → `ArrayMatMul2DF64` hook (reserved; bench keeps manual IKJ) |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | `mm_blocked_512` MIR fast path (unchanged structure) |
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | Manual IKJ (best local ratio vs MIR hook) |

## Quality table

| Axis | Before (dashboard) | After (local bench) | Locked? |
|------|-------------------:|--------------------:|---------|
| **Stability** | tier-0 N/A; checksum verify pass | verify pass (iterative ref) | yes |
| **Accuracy** | ulp drift documented | unchanged ulp band | yes |
| **Speed** | matmul_blocked 1.549×; matmul_naive 1.333× | matmul_blocked **1.27×**; matmul_naive **1.00×**; num_gmres **1.00×** | target ≤1.2× |
| **Memory** | — | — | — |

Local CSV (`benchmarks/results/latest.csv`, 2026-05-29):

```
matmul_blocked  li=0.0112s  cpp=0.0088s  ratio=1.27×
matmul_naive    li=0.0019s  cpp=0.0019s  ratio=1.00×
num_gmres       li=0.0005s  cpp=0.0005s  ratio=1.00×
```

Dashboard before (ingest):

```
matmul_blocked  li=0.0158s  cpp=0.0102s  ratio=1.549×
matmul_naive    li=0.0036s  cpp=0.0027s  ratio=1.333×
num_gmres       li=0.0007s  cpp=0.0005s  ratio=1.400×
```

## Commands

```bash
cd lic && ./scripts/build.sh
python3 benchmarks/harness/bench.py --tier 1 --only matmul_blocked --only matmul_naive --only num_gmres --runs 5
./scripts/check-tier1-li-vs-cpp.sh

# Ingest (benchmarks repo — do not hand-edit summary.json):
cd ../benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Deferred

- `matmul_blocked` still >1.2× locally — needs micro-kernel register blocking or init int→float cast (P-float).
- `ml_conv2d_forward`, `ml_mlp_forward`, `ml_mlp_train_step` — WP4 stub smokes; real kernels belong in **li-math** (separate PR).
- Yellow tier-2 thermostats (`md_thermostat_*`) — separate physics pass.
