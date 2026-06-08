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

## Phases

| Phase | Scope | Done when |
|-------|-------|-----------|
| **H** | OpenBLAS/native BLAS hook for `li_array_matmul` 32×32 | `li_rt_blas_sgemm_*` in runtime; `ml_blas_matmul_f32` + `li_array_matmul_blas_f32`; `LI_ARRAY_BLAS=openblas` dispatch; smoke + gate symbols green |
| **I** | Blocked GEMM tuning / tile size sweep | `ml_matmul_cpu_logical_32` tile params documented; sweep script or env `LI_ARRAY_GEMM_TILE`; measurable `li_over_numpy` delta vs Phase H baseline |
| **J** | Competitive bench refresh + ratio gate | `bench-ph-ml-li-array-matmul-32.sh` records `blas_backend`, fair workload notes; `ratio_target_met` warn-not-fail until ≤2.0 honest |

## Phase H exit criteria

- [x] `runtime/li_rt_blas.c` dlopen OpenBLAS + `cblas_sgemm` (no link-time `-lopenblas` required)
- [x] `ml_blas_matmul_f32` + `li_array_matmul_blas_f32` in packages
- [x] `ml_matmul_cpu_logical_32` tries BLAS before nested fallback when `LI_ARRAY_BLAS=openblas`
- [x] `docs/game-dev/specs/li-array-perf-blas-hook.md`
- [x] `scripts/ph-ml-li-array-perf-h-gates.sh` green (warn if `li_over_numpy` still ≫2.0)
- [ ] CI green on PR

## Phase I exit criteria

- [ ] Tile sweep for 8×8 / 16×16 micro-kernels documented in perf spec
- [ ] `li_over_numpy` improved vs Phase H baseline (honest pilot buffer limits noted)
- [ ] No regression on `ph-ml-li-array-gates.sh` smokes

## Phase J exit criteria

- [ ] `bench-ph-ml-li-array-matmul-32.json` includes `blas_backend` / `workload_class`
- [ ] Gate prints `ratio_target_met`; **warn** not hard-fail when still >2.0
- [ ] `ph-ml-competitive.json` row `li_array_matmul_32x32` refreshed

## Phase H perf investigation (post-#1320)

**Symptom:** Pod bench with `LI_ARRAY_BLAS=openblas` reported `li_over_numpy≈3320` vs Phase G `≈343` on the same workload.

**Findings (2026-06-08):**

| Check | Result |
|-------|--------|
| `cpu_sec` includes compile? | **No** — run-only 50× mean after 3 warmup; compile is separate (`build_cpu_sec` null). |
| `cblas_dgemm` row-major dims | **Correct** for 8×8×8, `ld=8` (`M,N,K` order, `lda=ldb=ldc=ld`). Li `float` codegen is f64, so `dgemm` matches storage (not `sgemm`). |
| dlopen per call? | **No** — `li_rt_blas_init_once()` guards load. |
| Root cause | **8×8 OpenBLAS dispatch** preempts Phase G `@vectorized` nested GEMM. On pod: `cpu_sec` 0.00306 (BLAS) vs 0.00066 (CPU) ≈ **4.7× slower**; vs NumPy 1µs → `li_over_numpy` ~3060 vs ~660. |
| Fix | Skip BLAS when `m·n·k < 4096` (16³); pin `OPENBLAS_NUM_THREADS=1` on init. Full 32×32 BLAS awaits denser buffer (Phase I/J). |

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
