# PH-ML li-array perf sprint I/J — dense 32×32 + tile sweep

**Sprint ID:** `ph-ml-li-array-perf-ij`  
**Repos:** `lic` (primary), `benchmarks` (competitive rows)  
**Branch:** `cursor/ph-ml-li-array-perf-ij` → `main`  
**Runner:** goal-directed SDK `code_implementer` (`LI_SWARM_EXTERNAL=1`, `--max 0` until gate passes)  
**Gate:** `bash scripts/ph-ml-li-array-perf-ij-gates.sh`  
**Prior sprint:** `data/goal-directed-sprints/ph-ml-li-array-perf-h.md` (Phase H **DONE**)  
**RFC:** `docs/game-dev/specs/li-array-rfc.md`  
**Perf study:** `docs/game-dev/specs/li-array-perf-gemv-gemm.md`, `docs/game-dev/specs/li-array-perf-blas-hook.md`

## Baseline (Phase H on main)

From `benchmarks/results/ph-ml-li-array-matmul-32.json`:

| Field | Value |
|-------|-------|
| `validity_gate_pass` | true |
| `li_over_numpy` | ~343× (Li slower; 8×8 pilot buffer) |
| `ratio_target_met` | false (target ≤2.0) |
| Hot path | `ml_matmul_cpu_logical_32` → 8×8 pilot or BLAS skip (`m·n·k < 4096`) |

Phase H wired OpenBLAS dlopen but the pilot `array[64]` only exercises 8×8×8 GEMM — below the 16³ BLAS crossover. NumPy runs full dense 32×32 `cblas_sgemm`.

## Goal

Close the ~343× gap toward NumPy CPU matmul @ 32×32:

1. **Phase I** — dense `array[1024]` 32×32 buffer, blocked CPU tile sweep (`LI_ARRAY_GEMM_TILE`), full 32³ BLAS when `LI_ARRAY_BLAS=openblas`.
2. **Phase J** — competitive bench refresh (`blas_backend`, `buffer_class`, `gemm_tile`), honest `ratio_target_met` warn-not-fail until ≤2.0.

## Status

| Phase | Status |
|-------|--------|
| **I** | **DONE** — dense BLAS path + tile sweep + in-process hot loop |
| **J** | **DONE** — bench metadata + competitive row refresh |

## Phases

| Phase | Scope | Done when |
|-------|-------|-----------|
| **I** | Dense 32×32 `array[1024]`, `ml_matmul_cpu_dense_blocked`, `LI_ARRAY_GEMM_TILE` env, tile sweep script | Gate symbols green; `li_over_numpy` improved vs Phase H baseline |
| **J** | Bench JSON metadata + competitive refresh | `blas_backend`, `buffer_class`, `gemm_tile` in JSON; gate warns when `ratio_target_met` false |

### Phase I

Deliverables:

- `ml_matmul_pilot_to_dense_32` + `li_rt_blas_matmul_dense32_identity` (full 32×32 dense in C; Li `array[1024]` awaits index refinements)
- `ml_matmul_cpu_dense_blocked` with `LI_ARRAY_GEMM_TILE` (`8` \| `16`)
- `scripts/bench-ph-ml-li-array-gemm-tile-sweep.sh` records per-tile `li_over_numpy`
- `docs/game-dev/specs/li-array-perf-gemv-gemm.md` tile sweep table

Exit criteria:

- [x] `ml_matmul_dense_init_identity_32` + dense path in `ml_matmul_cpu_logical_32`
- [x] `li_rt_gemm_tile_env` in runtime; `LI_ARRAY_GEMM_TILE` documented
- [x] Tile sweep script produces `benchmarks/results/ph-ml-li-array-gemm-tile-sweep.json`
- [x] `li_over_numpy` improved vs Phase H baseline (honest; target ≤2.0 still stretch)
- [x] `ph-ml-li-array-gates.sh` smokes still green

### Phase J

Deliverables:

- `bench-ph-ml-li-array-matmul-32.json`: `blas_backend`, `workload_class`, `buffer_class`, `gemm_tile`, `phase_h_baseline_li_over_numpy`
- Refresh `ph-ml-competitive.json` row `li_array_matmul_32x32`
- Gate prints `ratio_target_met`; **warn** not hard-fail when still >2.0

Exit criteria:

- [x] Bench JSON includes `buffer_class` (`dense_1024` \| `pilot_64`) and `gemm_tile`
- [x] `ph-ml-competitive.json` row refreshed from latest bench
- [x] `PH-ML-GPU-execution-tracker.md` li-array perf I/J row updated

## Agent rules

- Native Li only for perf measurements — exclude compile from `cpu_sec`.
- Never add NumPy-style silent broadcasting.
- Do not stub BLAS: if OpenBLAS missing, fall back to dense CPU blocked path and record `blas_backend: none`.
- One PR per phase when possible; merge when CI green.

## Progress gate

```bash
bash scripts/ph-ml-li-array-perf-h-gates.sh
```

## Completion gate

```bash
bash scripts/ph-ml-li-array-perf-ij-gates.sh
```
