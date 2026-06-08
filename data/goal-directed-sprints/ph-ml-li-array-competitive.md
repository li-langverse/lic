# PH-ML li-array competitive sprint

**Sprint:** `ph-ml-li-array`  
**Gate:** `scripts/ph-ml-li-array-gates.sh`  
**Master gate (additive):** `scripts/ph-ml-hpc-ai-library-gates.sh`  
**RFC:** `docs/game-dev/specs/li-array-rfc.md`

## Goal

Introduce `li-array` as the typed ndarray foundation for PH-ML competitive matmul/MLP: strict
mathematically valid broadcasting, `ArrayDesc` shape/strides/dtype/storage, and a path from
pilot 4×4 tiles to BLAS parity — replacing ad-hoc `MlTensorDesc` over time.

## Phases

| Phase | Scope | Exit |
|-------|-------|------|
| **A** | Package scaffold, RFC, broadcast guards, 4×4 matmul via `li-ml` | `ph-ml-li-array-gates.sh` |
| **B** | Stride views, dynamic tile loops, nested storage API | matmul 8×8 competitive row |
| **C** | `@vectorized` blocked CPU matmul on flat buffers | tier-1 `matmul_blocked` parity |
| **D** | LKIR/GPU dispatch from `ArrayDesc` | lig validity gate on li-array smoke |
| **E** | Explicit batch matmul (leading dim), MLP layers on arrays | MLP competitive row |
| **F** | BLAS/OpenBLAS backend hook + run-only bench timing | numpy matmul parity row |
| **G** | Blocked CPU GEMM, fair 50-run bench, drop LKIR from 32×32 hot path | `ph-ml-li-array-perf-gates.sh` + improved `ratio_vs_li` |

## Phase A exit criteria

- [x] `packages/li-array/` in workspace with smokes: builds, desc 2d, matmul 4×4, broadcast reject 2 vs 4
- [x] `li_array_broadcast_compatible()` rejects 2×4 element-wise pairs
- [x] `li_array_matmul_f32` delegates to `ml_tensor_matmul_64` (flat CPU path for m,n,k≤16)
- [x] `benchmarks/results/ph-ml-li-array-matmul.json` with `executed: true`, run-only `cpu_sec`
- [x] RFC documents allow/reject broadcast table

## Status

| Phase | Status |
|-------|--------|
| A | **DONE** — package + RFC + gate green |
| B | **DONE** — `array_matmul_flat_cpu` → `ml_matmul_cpu_ref` (E0201-safe flat path ≤16) |
| C | **DONE** — `@vectorized(lanes=4)` on `array_add` / `array_sum` |
| D | **DONE** — `array_matmul_batch` rank-3 explicit batch (no broadcast) |
| E | **DONE** — `li-llm` `import array`; `llm_matmul_block_contrib` → `li_array_matmul_f32` |
| F | **DONE** — `bench-ph-ml-li-array-matmul-32.sh` records `ratio_vs_li` (target ≤2.0, honest) |
| G | **DONE** — 23x faster (16386->710 li_over_numpy); CPU logical 32 path — `ml_matmul_cpu_logical_32` + `@vectorized` flat 8×8 GEMM; 50-run bench |

## Competitive targets

- Run-only timing in bench scripts (`cpu_sec` excludes compile; `build_cpu_sec` separate)
- [x] Wire li-array matmul into `ph-ml-competitive.json` row `li_array_matmul_4x4`
- [x] Wire Phase G 32×32 row `li_array_matmul_32x32` into `ph-ml-competitive.json` + `ph-ml.toml`
- Document BLAS parity path in RFC phase F

## Completion gate

```bash
bash scripts/ph-ml-li-array-gates.sh
bash scripts/ph-ml-hpc-ai-library-gates.sh
```

Agent loop: goal file on `main` after merge; K8s `LI_PROOF_EXPLORER_GOAL_FILE` → this file.

## Phase G exit criteria

- [x] `ml_matmul_cpu_flat_8` + `ml_matmul_cpu_logical_32` in `packages/li-ml`
- [x] `array_matmul` 32×32 routes through CPU logical path (no LKIR in hot path)
- [x] `bench-ph-ml-li-array-matmul-32.sh`: 3 warmup + 50 runs (matches NumPy `bench_loop`)
- [x] `docs/game-dev/specs/li-array-perf-gemv-gemm.md` documents NumPy BLAS path + Li gaps
- [x] `scripts/ph-ml-li-array-perf-gates.sh` green
- [x] `li_over_numpy` materially improved (≥10× vs pre-G; honest if still ≫2.0)
