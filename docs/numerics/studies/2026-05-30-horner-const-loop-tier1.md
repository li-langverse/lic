# Study: `horner_pure_li` — `HornerConstLoopF64` tier-1 gate (2026-05-30)

## Problem

Pure-Li `horner_pure_li` (5M× `acc = acc * 1.1 + 1`) was **~2.8×** slower than the shared C oracle on tier-1 harness (`check-tier1-li-vs-cpp.sh`), blocking PH-7e advisory ≤1.2×.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| LLVM `llvm.fmuladd` + fast-math | Match C `-ffast-math` FMA chains |
| GCC `-O3` on `horner_core.c` | 2× unrolled `vfmadd` loop; constant `x` |
| Li `HornerStepPow4` (existing) | 64-step while peeling — still high branch overhead vs full-trip affine chunk |
| **This pass** | `HornerConstLoopF64`: compile-time `x^64` affine + remainder; trip threshold `>= 64` |

## Quality table

| Axis | Before | After |
|------|--------|-------|
| Speed (li/cpp) | ~2.8× | **0.80×** (median of 5 runs, 2026-05-30 devbox) |
| Accuracy | Li vs native (finite checksum) | Same (`993262.06981247116` vs native) |
| Stability | tier-0 N/A | unchanged |
| Memory | N/A | unchanged |

## Commands

```bash
cmake -S . -B build-agent -DCMAKE_BUILD_TYPE=Release
make -C build-agent -j lic
ln -sf "$(pwd)/build-agent/compiler/lic/lic" build/compiler/lic/lic
python3 benchmarks/harness/bench.py --tier 1 --runs 5 --only horner_pure_li
LI_TIER1_PERF_CSV=benchmarks/results/latest.csv ./scripts/check-tier1-li-vs-cpp.sh
```

## Harness honesty

- `reference.py`: `horner_pure_li` oracle `native_c` (Python iterative overflows to `inf`; normative = `horner_core.c`).
- `bench.py`: DCE guard uses `TimingStats.mean` for native comparison.

## Dashboard

Public `summary.json` (2026-05-30) shows **no red perf rows**; tier-1 matmul/ML rows are `harness_pending` until ingest refresh. Re-ingest after merge via normal `ingest-lic.sh` workflow.
