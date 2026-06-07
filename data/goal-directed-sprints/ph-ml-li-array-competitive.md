# PH-ML li-array competitive — strict arrays → BLAS-fair benches

**Sprint ID:** `ph-ml-li-array`  
**Repos:** `lic` (primary), `benchmarks` (competitive rows)  
**Branch:** `cursor/ph-ml-li-array` (from `main`)  
**Runner:** goal-directed SDK `code_implementer` (`LI_SWARM_EXTERNAL=1`, `--max 0` until gate passes)  
**Gate:** `bash scripts/ph-ml-li-array-gates.sh`  
**RFC:** `docs/game-dev/specs/li-array-rfc.md`

## Goal

Make Li ML competitive via a proper array package: strict shape rules (no NumPy silent broadcasting), `ArrayDesc`/`LiArray` descriptors, ops bridged to `li-ml` LKIR matmul, and BLAS-fair benchmark rows at 32×32+ with compile excluded from timing.

## Phases

| Phase | Scope | Done when |
|-------|-------|-----------|
| **A** | `li-array` package, RFC, strict smokes, gate skeleton | `ph-ml-li-array-gates.sh` smokes pass; RFC merged |
| **B** | Flat storage hot path; reduce nested bridge on CPU | `array_matmul` uses flat loop for m,n,k≤16 without nested copy |
| **C** | `@vectorized` `array_add` / `array_sum` | smokes + perf delta on 1-D length 32 |
| **D** | Rank-3 batch matmul (explicit batch dim, no broadcast) | `array_matmul_batch` smoke; shape tests reject NumPy-style (B,1,n) |
| **E** | li-llm forward via `import array` | `llm_forward_matmul` uses `ArrayDesc`; retires direct `MlTensorDesc` in smokes |
| **F** | Competitive ratio vs NumPy @ 32×32+ | `bench-ph-ml-li-array-matmul-32.sh`; `ratio_vs_li ≤ 2.0`; gate exit 0 |

## Phase A exit criteria (initial PR)

- [x] `packages/li-array/` with `ArrayDesc`, `LiArray`, `array_matmul`, `array_add`, `array_sum`
- [x] Strict shape checks: `array_shape_equal`, `array_matmul_shape_ok`; reject smoke
- [x] Bridge to `ml_tensor_matmul_64` / LKIR path
- [x] Smokes with numeric assertions (`array_matmul_4`, `array_add_same_shape`, `array_sum_1d`)
- [x] `li-tests/manifest.toml` entry via package manifest
- [x] RFC `docs/game-dev/specs/li-array-rfc.md`
- [ ] Gate script green on CI

## Status

| Phase | Status |
|-------|--------|
| A | **IN PROGRESS** — package + RFC landed; gate + K8s pending |
| B | pending |
| C | pending |
| D | pending |
| E | pending |
| F | pending |

## Agent rules

- Never add NumPy-style silent broadcasting to `array_add` or `array_matmul`.
- Document any new broadcast-like op with explicit name + RFC amendment.
- One PR per phase when possible; merge when CI green.
- Update `docs/game-dev/PH-ML-GPU-execution-tracker.md` when Phase F completes.
- Do not weaken `ph-ml-li-array-gates.sh` to exit 0 without real smokes.

## Completion gate

```bash
bash scripts/ph-ml-li-array-gates.sh
```

Milestone-only (Phase A): smokes compile + run; grep for `array_shape_equal` in `packages/li-array/src/lib.li`.

Full program (Phase F): gate includes `bench-ph-ml-li-array-matmul-32.sh` with `ratio_vs_li ≤ 2.0`.
