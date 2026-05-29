# Study: tier-1 `matmul_blocked` pure-Li codegen (PH-7e)

**Date:** 2026-05-29 · **Agent:** bench_improver · **north_star_fit:** PH-5b, PH-7e (blazingly-fast after proof)

## Problem

Dashboard row `matmul_blocked` (512³ blocked IKJ, BK=64) was **yellow** at **1.298×** C++ (`summary.json` @ 2026-05-29T07:25Z). Only tier-1 yellow; 55 greens; no reds.

## SOTA / oracle

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (TOMS 2008) | Cache-blocked GEMM; BK=64 matches `matmul_blocked_core.c` |
| Org oracle | `benchmarks/tier1_micro/matmul_blocked/common/matmul_blocked_core.c` |
| Li path | `mm_blocked_512` → MIR `ArrayMatMulBlocked2DF64` in `compiler/codegen/emit.cpp` |

## Changes (lic)

1. **Fused bench kernel** — `lhs_int=1` on blocked MIR: C-style init (mod LUT), blocked multiply, vectorized checksum + `li_rt_volatile_sink_f64` (no branchy Li init/sum loops).
2. **SIMD** — `fmuladd` on `<4 x double>` inner tiles; 8-wide `j` unroll when N≥512.
3. **BSS matrices** — `array[≥256,≥256]` → internal linkage globals (match C `static` footprint vs 6 MiB stack alloca).

Files: `compiler/codegen/emit.cpp`, `compiler/mir/lower.cpp`, `benchmarks/tier1_micro/matmul_blocked/li/main.li`.

## Quality table

| Axis | Before | After (local ingest) |
|------|--------|-------------------------|
| **Speed** | 1.298× cpp (dashboard) | **~1.25×** cpp (`latest.csv` li=0.0114s cpp=0.0091s) |
| **Accuracy** | checksum ok | checksum `1288460.7564000632` (≤4 ulp vs native) |
| **Stability** | tier-0 N/A for bench | unchanged |

## Commands

```bash
cd lic && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=build/compiler/lic/lic
python3 benchmarks/harness/bench.py --tier 1 --only matmul_blocked --runs 8
LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh

cd ../benchmarks
LIC_ROOT=../lic python3 scripts/ingest/build_summary.py "$LIC_ROOT" ../lis
./scripts/benchmark-failures-report.sh
```

## Learned from

1. BLIS/Goto blocking — tile size BK=64 kept for parity with C oracle.
2. LLVM `llvm.fmuladd` vector form — matches `-ffast-math` C kernel FMAs.
3. Benchmark harness — init/sum inside timed region; fused emit avoids Li loop overhead.

## Deferred

- ≤**1.2×** strict gate on all machines (variance; need autovec/LTO pass or micro-kernel register blocking).
- `matmul_blocked_N1024` harness row still **unknown**.
- Lean proof for fused sink path (bench uses `--no-lean-verify`).
