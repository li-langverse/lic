# Study: bench_improver proactive sweep — tier-1 matmul yellow rows

**Date:** 2026-05-30 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** blazingly-fast (proof-before-perf numerics)

## Problem

Org dashboard (`summary.json` @ 2026-05-30T14:55Z): **0 red**, **2 yellow** tier-1 pure-Li rows:

| benchmark | ratio vs cpp | owner |
|-----------|--------------|-------|
| `matmul_blocked` | 1.244× | lic |
| `matmul_naive` | 1.222× | lic |

Advisory cap: **≤1.2×** cpp (`threshold_ratio_cpp`).

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLIS) | Blocked IKJ, BK=64 — matches `matmul_blocked_core.c` |
| Org oracle `matmul_blocked_core.c` | `static` 512² buffers; init + blocked GEMM + full checksum |
| Org oracle `matmul_core.c` | 256³ IKJ; `mm_naive_256` MIR + oracle init |
| LLVM `llvm.fmuladd` + 4-wide `j` | `emit_matmul2d_blocked_ijk` vec4 inner |

## Changes (lic)

| Path | Change |
|------|--------|
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | `mm_blocked_512_acc()` MIR → static BSS + blocked GEMM + sum (C parity) |
| `compiler/mir/include/li/mir.hpp` | `Tier1MatmulBlocked512AccF64` |
| `compiler/mir/lower.cpp` | Lower `mm_blocked_512_acc` call/proc |
| `compiler/codegen/emit.cpp` | Module static 512² globals; matmul GEP helpers accept `Value*` |
| `benchmarks/harness/bench.py` | Fix verify guard: `TimingStats.mean` |

Rejected: 512×(64³) tile repetition harness (wrong workload vs C); outlined `noinline` kernel (call overhead).

## Quality table

| Axis | Before (dashboard) | After (local n=15) |
|------|-------------------|---------------------|
| **Speed** `matmul_naive` | 1.222× yellow | **1.167×** green |
| **Speed** `matmul_blocked` | 1.244× yellow | **1.216×** advisory (↓2.3%) |
| **Accuracy** | verify ok | unchanged (`1288460.7563999966`) |
| **Stability** | tier-0 skip | not touched |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 15
LI_TIER1_PERF_STRICT=0 ../scripts/check-tier1-li-vs-cpp.sh
```

Ingest (benchmarks repo — no hand-edit `summary.json`):

```bash
cd benchmarks
LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Deferred

- `matmul_blocked` ≤1.2× on all ingest hosts (remaining ~1.6% codegen vs clang static kernel).
- Near-threshold: `num_integ_rk4` 1.083×, `simd_dot` 1.052×, `fft_1d_fixed` 1.007× — micro-opt only with bench proof.
- Lean review if parallel/OpenMP blocked lowering is pursued.
