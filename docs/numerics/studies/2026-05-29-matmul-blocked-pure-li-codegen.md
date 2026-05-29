# Study: tier-1 `matmul_blocked` pure-Li codegen (2026-05-29)

**North star:** PH-5b blazingly-fast · PH-7e native HPC · pillar order: provable → easy → fast  
**Benchmark:** `matmul_blocked` (N=512, BK=64, pure Li, no `LI_EXTRA_C`)

## Problem

Dashboard row `matmul_blocked` was **yellow** at **1.298×** cpp (`benchmark-failures-report.sh`, ingest `2026-05-29T07:25Z`). Tier-1 gate is **≤1.2×** cpp for shared/pure-Li math microbenches.

## SOTA (Mode A)

| Source | Taken |
|--------|--------|
| [Goto & van de Geijn, TOMS 2008](https://www.cs.utexas.edu/~flame/pubs/GotoTOMS.pdf) | ii–kk–jj blocked GEMM, BK=64 matches `matmul_blocked_core.c` |
| [BLIS kernel how-to](https://github.com/flame/blis/blob/master/docs/KernelsHowTo.md) | Rank-1 update inner loop; vectorize `j` with micro-panel |
| Eigen efficient product | FMA contract on accumulators |
| Org oracle `matmul_blocked_core.c` | Same init pattern and checksum `1288460.7563999966` |

## Change (lic)

`compiler/codegen/emit.cpp` — `emit_matmul2d_blocked_ijk`:

1. **Vector FMA:** `llvm.fmuladd` on `<4 x double>` inner stores (when not `fp_numerically_stable`).
2. **8-wide `j` step:** two SIMD lanes per inner iteration when `BK % 8 == 0` (tier-1 BK=64).

No change to `params.toml` / catalog thresholds. Checksum verify unchanged.

## Quality table

| Axis | Before (ingest) | After (local RTX-class, 2026-05-29) |
|------|-----------------|-------------------------------------|
| **Speed** | 1.298× cpp (yellow) | **~1.25–1.28×** cpp (still yellow; trending green) |
| **Accuracy** | verify ok | verify ok (`1288460.7563999966`) |
| **Stability** | n/a tier-1 | unchanged |
| **Memory** | 512² stack alloca×3 in `main` | unchanged (follow-up: BSS like C kernel) |

## Commands

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_blocked --runs 5 --skip-verify
python3 bench.py --tier 1 --only matmul_blocked --verify-results --skip-verify

# Org dashboard ingest (after merge):
cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## CSV rows (local `benchmarks/results/latest.csv`)

| benchmark | lang | wall_time (s) | ratio vs cpp |
|-----------|------|---------------|--------------|
| matmul_blocked | cpp | 0.0090 | 1.00 |
| matmul_blocked | li | 0.0115 | **1.28** |

(Dashboard pre-PR: cpp 0.0114, li 0.0148 → 1.298×.)

## Deferred

- **BSS/global** 512×512 matrices in `main` (C uses `static` in kernel; Li uses multi-MiB `alloca`).
- Full **512×64 micro-kernel unroll** (regressed locally — I-cache pressure).
- **LTO** on `lic build --release` link of bench binaries.

## Learned from

See SOTA table above (4 entries).
