# PH-ML li-array perf sprint H — OpenBLAS parity path

**Sprint ID:** `ph-ml-li-array-perf-h`  
**Repos:** `lic` (primary), `benchmarks` (competitive rows)  
**Branch:** `cursor/ph-ml-li-array-perf-h` → `main`  
**Runner:** goal-directed SDK `code_implementer` (`LI_SWARM_EXTERNAL=1`, `--max 0` until gate passes)  
**Gate:** `bash scripts/ph-ml-li-array-perf-h-gates.sh`  
**Prior sprint:** `data/goal-directed-sprints/ph-ml-li-array-competitive.md` (Phases A–G **DONE**)  
**RFC:** `docs/game-dev/specs/li-array-rfc.md` (Phase F BLAS hook notes)  
**Perf study:** `docs/game-dev/specs/li-array-perf-gemv-gemm.md` (Phase G baseline)

## Baseline (Phase G on main)

From `benchmarks/results/ph-ml-li-array-matmul-32.json`:

| Field | Value |
|-------|-------|
| `validity_gate_pass` | true |
| `li_over_numpy` | ~343× (Li slower) |
| `ratio_target_met` | false (target ≤2.0) |
| Hot path | `ml_matmul_cpu_logical_32` → 8×8 `@vectorized` nested GEMM |

Phase G removed LKIR from the 32×32 hot path but Li is still far from NumPy/OpenBLAS.

## Goal

Close the remaining ~343× gap toward NumPy CPU matmul @ 32×32 using native Li only in the timing path (no Python in hot loop). Primary lever: OpenBLAS `cblas_sgemm` via runtime dlopen; secondary: blocked GEMM tile tuning.

## Status

| Phase | Status |
|-------|--------|
| **H** | **DONE** — OpenBLAS dlopen hook + pilot 8×8 dispatch |
| **I** | **MOVED** → `data/goal-directed-sprints/ph-ml-li-array-perf-ij.md` |
| **J** | **MOVED** → `data/goal-directed-sprints/ph-ml-li-array-perf-ij.md` |

## Phases

| Phase | Scope | Done when |
|-------|-------|-----------|
| **H** | OpenBLAS/native BLAS hook for `li_array_matmul` 32×32 | `li_rt_blas_sgemm_*` in runtime; `ml_blas_matmul_f32` + `li_array_matmul_blas_f32`; `LI_ARRAY_BLAS=openblas` dispatch; smoke + gate symbols green |
| **I** | *(continued in perf-ij sprint)* | — |
| **J** | *(continued in perf-ij sprint)* | — |

### Phase H

## Phase H exit criteria

- [x] `runtime/li_rt_blas.c` dlopen OpenBLAS + `cblas_sgemm` (no link-time `-lopenblas` required)
- [x] `ml_blas_matmul_f32` + `li_array_matmul_blas_f32` in packages
- [x] `ml_matmul_cpu_logical_32` tries BLAS before nested fallback when `LI_ARRAY_BLAS=openblas`
- [x] `docs/game-dev/specs/li-array-perf-blas-hook.md`
- [x] `scripts/ph-ml-li-array-perf-h-gates.sh` green (warn if `li_over_numpy` still ≫2.0)
- [ ] CI green on PR

Phase I/J continue in **`ph-ml-li-array-perf-ij.md`** (dense `array[1024]`, tile sweep, competitive refresh).

## Phase H perf investigation (post-#1320)

**Symptom:** Pod bench with `LI_ARRAY_BLAS=openblas` reported `li_over_numpy≈3320` vs Phase G `≈343` on the same workload.

**Findings (2026-06-08):**

| Check | Result |
|-------|--------|
| `cpu_sec` includes compile? | **No** — run-only 50× mean after 3 warmup; compile is separate (`build_cpu_sec` null). |
| `cblas_dgemm` row-major dims | **Correct** for 8×8×8, `ld=8` (`M,N,K` order, `lda=ldb=ldc=ld`). Li `float` codegen is f64, so `dgemm` matches storage (not `sgemm`). |
| dlopen per call? | **No** — `li_rt_blas_init_once()` guards load. |
| Root cause | **Two issues:** (1) 8×8 `cblas_dgemm` loses to `@vectorized` CPU; (2) `ml_blas_matmul_f32` called `li_rt_blas_sgemm_ready()` before the size gate, so **every bench subprocess paid `dlopen`** (~50× per gate). Pod: `cpu_sec` 0.00306 (BLAS env) vs 0.00066 (CPU off). |
| Fix | Skip BLAS when `m·n·k < 4096` (16³) **before** `dlopen`; call `li_rt_blas_sgemm_f32` directly (no `ready()` first); pin `OPENBLAS_NUM_THREADS=1`. Full 32×32 BLAS awaits denser buffer (Phase I/J). |

## Agent rules

- Native Li only for perf measurements — exclude compile from `cpu_sec`.
- Never add NumPy-style silent broadcasting.
- Do not stub BLAS: if OpenBLAS missing, fall back to Phase G CPU path and record `blas_backend: none`.
- One PR per phase when possible; merge when CI green.
- Update `docs/game-dev/PH-ML-GPU-execution-tracker.md` when Phase J completes.

## Completion gate

```bash
bash scripts/ph-ml-li-array-perf-h-gates.sh
```

Full program (Phase J): includes `bench-ph-ml-li-array-matmul-32.sh` with honest `ratio_target_met` reporting.
