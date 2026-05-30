# Study: restore tier-1 matmul MIR fast paths (bench_improver)

**Date:** 2026-05-30  
**North star:** PH-5b, PH-7e — tier-1 pure-Li matmul ≤1.2× C++ (advisory)  
**Repo:** lic  

## Problem

Dashboard ingest (2026-05-29) still red on `matmul_blocked` (1.549×), `matmul_naive` (1.333×). Agent branch had regressed Li drivers to `C = A @ B` (full 512³ `ArrayMatMul2DF64` loop path) instead of cache-blocked `mm_blocked_512` and manual 256³ IKJ matching the C oracle.

## SOTA / Learned from

1. **Goto & van de Geijn (2008)** — blocked IKJ micro-kernels; BK=64 matches `matmul_blocked_core.c`.
2. **LLVM fmuladd** — FMA in `emit_matmul2d_blocked_ijk` / IKJ loops (`-ffast-math`).
3. **Org oracle** — `benchmarks/tier1_micro/*/common/*_core.c`; Li init + hot loop structure must mirror C++.
4. **Prior lic study** — `docs/numerics/studies/2026-05-29-tier1-matmul-codegen.md` (local green naive, blocked gap).

## Quality table

| Axis | matmul_naive | matmul_blocked |
|------|--------------|----------------|
| **Stability** | unchanged (checksum) | unchanged |
| **Accuracy** | verify vs spec | verify vs spec |
| **Speed (local)** | **1.000×** cpp (was 1.333× dash) | **1.291×** cpp (was 1.549× dash) |
| **Memory** | stack 256³ (harness) | stack 512³ (harness) |

## Changes

| Path | Change |
|------|--------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | IKJ hot loop (not `@`) |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | `mm_blocked_512(C,A,B)` MIR hook |
| `compiler/codegen/emit.cpp` | PHI-based matmul loop induction (LLVM opt friendly) |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=./build/compiler/lic/lic
python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres --runs 5
./scripts/check-tier1-li-vs-cpp.sh
cd ../benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```

## Deferred

- `num_gmres` / `ml_*` — shared C or li-math; separate agents.
- Yellow tier-2 thermostats — micro-opt pass.
- `matmul_blocked` if still >1.2× after ingest: static buffer parity with C `static` arrays (human ABI review).
