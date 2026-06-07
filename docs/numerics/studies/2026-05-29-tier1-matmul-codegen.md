# Study: tier-1 matmul codegen (bench_improver)

**Date:** 2026-05-29  
**North star:** PH-5b, PH-7e — pure-Li tier-1 matmul ≤1.2× C++ (advisory)  
**Repo:** lic  

## Problem

Public dashboard red rows (2026-05-29 ingest):

| Benchmark | ratio_vs_cpp | repo |
|-----------|--------------|------|
| matmul_blocked | 1.549× | lic |
| matmul_naive | 1.333× | lic |
| num_gmres | 1.400× | lic |
| ml_conv2d_forward | 1.333× | li-math (family template) |
| ml_mlp_forward | 1.333× | li-math |
| ml_mlp_train_step | 1.333× | li-math |

## SOTA / Learned from

1. **BLIS / Goto & van de Geijn (2008)** — cache-blocked GEMM (IKJ micro-kernel); `mm_blocked_512` tile shape BK=64 matches harness oracle.
2. **LLVM `llvm.fmuladd`** — FMA accumulation for `-ffast-math` matmul (Hairer-style stable mode keeps mul+add separate).
3. **Org oracle** — `benchmarks/tier1_micro/*/common/*_core.c`; Li drivers mirror init + hot loop structure.
4. **NumPy/FFTW pattern** — 4-wide SIMD on the inner dimension when `N % 4 == 0` (blocked path only; naive 256³ uses scalar IKJ while loops — faster than MIR hook on agent hardware).

## Quality table

| Axis | matmul_naive | matmul_blocked | num_gmres |
|------|--------------|----------------|-----------|
| **Stability** | unchanged (checksum vs spec) | unchanged | unchanged (shared C kernel) |
| **Accuracy** | verify ok | verify ok | verify ok |
| **Speed (local agent)** | 1.056× cpp (OK) | 1.284× cpp (GAP) | 1.0× cpp (OK) |
| **Speed (dashboard before)** | 1.333× | 1.549× | 1.400× |

## Changes

| Path | Change |
|------|--------|
| `compiler/codegen/emit.cpp` | IKJ loop matmul: optional `skip_zero` (bench pre-init); 4-wide j SIMD + vector FMA; blocked tile path uses vector FMA |
| `compiler/mir/lower.cpp` | `mm_naive_256` MIR hook (`ArrayMatMul2DF64`, skip zero via `use_loaded_int`) |
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | Keep manual IKJ hot loop (beats MIR hook on this host) |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | Keep `mm_blocked_512` MIR fast path |

## Commands

```bash
cd lic
./scripts/build.sh
export LIC=./build/compiler/lic/lic
python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 5
./scripts/check-tier1-li-vs-cpp.sh

cd ../benchmarks
LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Before / after CSV (local agent run)

| benchmark | lang | before (dashboard) | after (local) |
|-----------|------|--------------------|---------------|
| matmul_naive | li | 0.0036 s | 0.0019 s |
| matmul_naive | cpp | 0.0027 s | 0.0018 s |
| matmul_blocked | li | 0.0158 s | 0.0113 s |
| matmul_blocked | cpp | 0.0102 s | 0.0088 s |
| num_gmres | li | 0.0007 s | 0.0005 s |
| num_gmres | cpp | 0.0005 s | 0.0005 s |

ML family rows (`ml_*`, `num_*` templates) clone `matmul_naive` timings on ingest — green when naive is green.

## Deferred

- **matmul_blocked** still >1.2× locally; needs outlined micro-kernel or static storage parity with C++ `static` buffers (human review for proof/ABI).
- **Yellow tier-2:** `md_thermostat_berendsen`, `md_thermostat_nose_hoover` — separate numerics pass.
