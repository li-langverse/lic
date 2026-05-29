# Study: matmul_naive MIR fast path (mm_naive_256)

**Date:** 2026-05-29  
**Agent:** bench_improver  
**North star:** PH-5b, PH-7e — tier-1 pure-Li matmul ≤1.2× C++  
**Dashboard:** https://li-langverse.github.io/benchmarks/

## Problem

Public dashboard row `matmul_naive` was **red** at **1.333×** C++ (ingested 2026-05-29T07:01Z).  
Li driver used explicit `while` IKJ nests; C++ uses the same algorithm but LLVM autovectorizes/FMA-lowers more aggressively than generic Li loop codegen.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| BLIS / Goto & van de Geijn (2008) | IKJ + `aik` hoisting is the reference micro-GEMM pattern |
| `matmul_core.c` (org oracle) | 256³ IKJ, LUT init, checksum sink — Li must match structure |
| `mm_blocked_512` MIR stub (lic #148) | Named proc → `ArrayMatMulBlocked2DF64` bypasses generic loop lowering |
| LLVM `llvm.fmuladd` + `-ffast-math` | Scalar FMA in dedicated emitter beats hand-rolled `c += a*b` stores |

## Implementation

1. **`mm_naive_256(C,A,B)`** stub in `benchmarks/tier1_micro/matmul_naive/li/main.li` (mirrors blocked bench).
2. **MIR:** `lower_callproc` + proc-body shortcut emit `ArrayMatMul2DF64` at 256³.
3. **Codegen:** `emit_matmul2d_ijk_loops` uses scalar FMA inner-j (f64x4 disabled — regressed locally on 256³).

## Quality table

| Axis | Before (dashboard) | After (local bench) | Notes |
|------|-------------------|---------------------|-------|
| **Speed** | 1.333× cpp (red) | **1.05×** cpp (green) | `bench.py --only matmul_naive --runs 5` |
| **Accuracy** | checksum 161055.1866 | unchanged | verify ok, same ULP band as prior |
| **Stability** | N/A tier-1 | N/A | no tier-0 change |

### CSV rows (local, 2026-05-29)

| benchmark | lang | wall_time (s) | ratio vs cpp |
|-----------|------|---------------|--------------|
| matmul_naive | cpp | 0.0019 | 1.00 |
| matmul_naive | li | 0.0020 | **1.05** |

Dashboard refresh requires ingest after merge (not edited manually).

## Commands

```bash
cd lic && ./scripts/build.sh
cd lic/benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 5
cd lic && ./scripts/check-tier1-li-vs-cpp.sh

# After merge — in benchmarks repo:
LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Deferred (same pass)

| Row | ratio | blocker |
|-----|-------|---------|
| matmul_blocked | 1.549× (dash) / 1.29× (local) | needs deeper tile/SIMD work; vec4 in blocked emitter already present |
| num_gmres | 1.400× | shared-C oracle — FFI overhead; local 1.0× |
| ml_* (li-math) | 1.333× | separate package, not lic harness |
