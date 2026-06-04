# PH-SCI-GPU-CHEM — GPU DFT / computational chemistry

**Status:** Wave 0 landed (2026-06-04) — CPU lib kernels + `@gpu` smokes PH-SCI-GPU-16/17  
**Branch:** `cursor/ph-sci-gpu-chem-dft`  
**Parent:** [ph-sci-simulation-gap-close-plan.md](ph-sci-simulation-gap-close-plan.md) (Phase 3 vendor GPU) · [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md) (LKIR / Stage 2)

## Vision

**GPU DFT** is the headline science feature: density-functional theory energy and SCF loops on `@gpu` with MIR placement today, LKIR/vendor lowering in Phase 3 (aligned with PH-ML Wave 2 / Stage 2 matmul spine).

## Stub vs real (audit 2026-06-04)

| Area | Before | Now | Full DFT (future) |
|------|--------|-----|-------------------|
| `chem_dft_energy_stub_hartree` | Constant −76 Hartree | Unchanged (Studio MCP legacy) | Replaced by converged SCF energy |
| `chem_dft_run_smoke` | Returned stub | Returns `chem_dft_energy_kernel_hartree()` | Full basis set + XC functional |
| `chem_dft_energy_kernel_hartree` | — | 8-point radial grid, mini STO-3G contraction, kin/pot/XC stub | Gaussian primitives + ERIs |
| `chem_dft_scf_iteration_scaffold` | — | Density mixing loop (6 iter max in checksum) | Diagonalization / Fock build |
| `drug_litl_dft_energy_for_stage` | `chem_dft_run_smoke()` | `chem_dft_energy_kernel_hartree()` | GPU queue + conformers |
| `physics_gpu_chem_combustion` | Real combustion loops | Unchanged (PH-SCI-GPU-06) | — |
| `drug_gpu_litl_workflow` | LITL tick smoke | Unchanged (PH-SCI-GPU-15) | — |
| LKIR CUDA emit for chem | None | None (WP-SCI-GPU-CHEM-04) | Same path as `ml_gpu_lkir_launch` |

## Work packages

### WP-SCI-GPU-CHEM-01 — `@gpu` DFT energy kernel

- **Goal:** `@gpu` smoke calls `chem_dft_energy_kernel_hartree()` with real grid/basis arithmetic (not MIR-only).
- **Scope:** `packages/li-chem/src/lib.li`, `packages/li-chem/li-tests/smoke/chem_gpu_dft_energy.li`.
- **Deliverables:** STO-3G-style `chem_dft_basis_eval_sto3g`, density fill, energy functional.
- **Acceptance:** PH-SCI-GPU-16 `compile_open_ok`; `ensures` checksum in `(0,1]` on kernel path.
- **Status:** done (CPU lib; GPU placement via `@gpu` decorator).

### WP-SCI-GPU-CHEM-02 — `@gpu` SCF iteration scaffold

- **Goal:** Fixed-point density mixing loop exposed as `chem_dft_scf_iteration_scaffold` + `chem_dft_gpu_energy_checksum`.
- **Scope:** `li-chem` lib (same file as WP-01).
- **Acceptance:** SCF smoke uses checksum contract `0..1`; energy remains `<= 0` Hartree-scale.
- **Status:** done (scaffold; no Fock matrix yet).

### WP-SCI-GPU-CHEM-03 — Drug-design LITL DFT stage coupling

- **Goal:** LitL stage 2 (`drug_litl_stage_dft`) uses kernel energy; dedicated `@gpu` smoke.
- **Scope:** `li-sim-drug-design`, `drug_gpu_dft_stage.li`, composable smokes.
- **Acceptance:** PH-SCI-GPU-17; `run_drug_design_smoke` checks `chem_dft_energy_kernel_hartree()`.
- **Status:** done.

### WP-SCI-GPU-CHEM-04 — LKIR / vendor path (future)

- **Goal:** Lower `chem_dft_energy_from_density` inner loops via LKIR like `ml_gpu_matmul_lkir_progress` / `ml_gpu_lkir_launch_pipeline`.
- **Scope:** `lig`, compiler `@gpu` backend, optional `LIG_EMIT_CUDA=1` build.
- **Dependencies:** PH-ML Stage 2 spine, WP-SCI-GPU-VENDOR-01 from gap-close plan.
- **Acceptance:** Non-empty kernel blob; device-buffer readback parity vs CPU oracle (documented tolerance).
- **Status:** planned.

## PH-ML Phase 3 hook (science chem)

From [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md):

| PH-ML wave | Science chem hook |
|------------|-------------------|
| Wave 2 / Stage 2 | Reuse LKIR matmul spine for ERIs / grid operators |
| Wave 11–13 | Device buffers + `ml_gpu_device_buffer_pipeline` pattern for density grids |
| Phase 3 (gap-close) | WP-SCI-GPU-VENDOR-01 pilot on numerics or **chem DFT grid loops** after CHEM-01/02 green |

Recommended order: land CHEM-01..03 (this doc) → vendor pilot on `chem_dft_energy_from_density` double loop → drug queue (WP-DRUG-04).

## CI

```bash
# WSL from lic repo root
bash scripts/ph-sci-gpu-chem-gates.sh
# or
bash scripts/check-science-gpu-gate.sh
```

Optional MIR enforcement:

```bash
PH_SCI_REQUIRE_MIR_GPU=1 bash scripts/check-science-gpu-gate.sh
```

## science_gpu IDs

| ID | Test | Package |
|----|------|---------|
| PH-SCI-GPU-16 | `chem_gpu_dft_energy.li` | li-chem |
| PH-SCI-GPU-17 | `drug_gpu_dft_stage.li` | li-sim-drug-design |

Existing PH-SCI-GPU-06 (combustion) and PH-SCI-GPU-15 (LitL workflow) remain; DFT is additive.
