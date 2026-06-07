# Study: tier-1 matmul — route hot path through `ArrayMatMul2DF64`

**Date:** 2026-05-29 · **Benches:** `matmul_naive` (N=256), `matmul_blocked` (N=512) · **PH:** PH-5b, PH-7e

## Problem

Pure-Li tier-1 matmul drivers used manual `while` IKJ loops (or a no-op `mm_blocked_512` stub on the agent branch). The compiler already lowers `C = A @ B` to `MirOp::ArrayMatMul2DF64` with LLVM `fmuladd` (IKJ, `-ffast-math`), but the benches bypassed that path.

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| BLAS reference (Goto & van de Geijn) | IKJ + cache blocking for large N; C oracle uses 64³ tiles |
| LLVM `llvm.fmuladd` | Fused multiply-add on the `@` lowering path |
| Org oracle `common/matmul_*_core.c` | Scalar/blocked IKJ; checksum parity unchanged |
| `docs/release-notes/2026-05-22-tier1-matmul-bench-hotloop.md` | Init hoisted; `@` lowering was the missing step |

## Change

| Path | What |
|------|------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | `C = A @ B` after LUT init |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | Remove stub `mm_blocked_512`; `C = A @ B` after init |

## Quality table

| Axis | `matmul_naive` before (dashboard) | `matmul_naive` after (local n=200) | `matmul_blocked` before | `matmul_blocked` after (local n≈88–111) |
|------|-----------------------------------|-------------------------------------|-------------------------|------------------------------------------|
| **Speed** | Li/cpp **1.333×** | **~1.05×** (≤1.2× cap) | **1.549×** | **~1.30×** (still above cap) |
| **Accuracy** | verify vs iterative | unchanged | verify ok | unchanged |
| **Stability** | N/A tier-0 | unchanged | N/A | unchanged |

## Commands

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
export LIC=$PWD/build/compiler/lic/lic
python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 5
./scripts/check-tier1-li-vs-cpp.sh
```

## Dashboard

Re-ingest after lic merge: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

## Follow-up

- **matmul_blocked:** blocked `ArrayMatMul2DF64` (64³ tiles) in codegen to match C cache blocking — target ≤1.2× without hand-written Li loops.
- **num_gmres / ml_*:** shared-kernel or **li-math** repos; dashboard reds may be CI-stale (local parity ~1.0× on gmres).
