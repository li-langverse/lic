# PH-SCI-GPU-CHEM — GPU DFT / computational chemistry

**Status:** Wave 1 landed (2026-06-04) — CHEM-04 Fock/SCF + LDA/XC + LKIR smokes PH-SCI-GPU-16/17/18; Wave 2 (2026-06-05) — electrochemistry stubs PH-SCI-GPU-19  
**Branch:** `cursor/ph-sci-gpu-chem-dft`  
**Parent:** [ph-sci-simulation-gap-close-plan.md](ph-sci-simulation-gap-close-plan.md) (Phase 3 vendor GPU) · [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md) (LKIR / Stage 2) · [ph-sci-electrochemistry-sim-plan.md](ph-sci-electrochemistry-sim-plan.md) (easy electrochemistry P0)

## Vision

**GPU DFT** is the headline science feature: density-functional theory energy and SCF loops on `@gpu` with MIR placement today, LKIR/vendor lowering in Phase 3 (aligned with PH-ML Wave 2 / Stage 2 matmul spine).

## Stub vs real (audit 2026-06-04)

| Area | Before | Now | Full DFT (future) |
|------|--------|-----|-------------------|
| `chem_dft_energy_stub_hartree` | Constant −76 Hartree | Unchanged (Studio MCP legacy) | Replaced by converged SCF energy |
| `chem_dft_run_smoke` | Returned stub | Returns `chem_dft_energy_kernel_hartree()` | Full basis set + XC functional |
| `chem_dft_energy_kernel_hartree` | — | 8-point radial grid, mini STO-3G contraction, kin/pot/LDA/Hartree | Gaussian primitives + ERIs |
| `chem_dft_scf_iteration_scaffold` | Density mixing only | Fock diagonal + power eigensolve + mixing | Full Fock matrix + GGA |
| `chem_dft_overlap_build` | — | 4×4 overlap on radial grid | General N×N Gaussian integrals |
| `chem_dft_run_gpu_queue` | — | Kernel energy + LKIR launch pipeline stub | Async GPU job queue |
| `drug_litl_dft_energy_for_stage` | `chem_dft_run_smoke()` | `chem_dft_energy_kernel_hartree()` | GPU queue + conformers |
| LKIR CUDA emit for chem | None | PH-SCI-GPU-18 via matmul spine reuse | Dedicated chem grid kernel |

## Work packages

### WP-SCI-GPU-CHEM-01 — `@gpu` DFT energy kernel

- **Status:** done (CPU lib; GPU placement via `@gpu` decorator).

### WP-SCI-GPU-CHEM-02 — `@gpu` SCF iteration scaffold

- **Status:** done; extended by CHEM-04a Fock step.

### WP-SCI-GPU-CHEM-03 — Drug-design LITL DFT stage coupling

- **Status:** done.

### WP-SCI-GPU-CHEM-04 — LKIR / vendor path

- **Goal:** Lower `chem_dft_energy_from_density` inner loops via LKIR like `ml_gpu_matmul_lkir_progress` / `ml_gpu_lkir_launch_pipeline`.
- **Deliverables (2026-06-04):**
  - **04a:** `chem_dft_overlap_build`, `chem_dft_fock_diagonal_build`, `chem_dft_eigensolve_power4`, `chem_dft_scf_fock_step`
  - **04b:** `chem_dft_lda_xc_density`, `chem_dft_hartree_grid`, `chem_dft_coulomb_2center`
  - **04c:** `chem_dft_gpu_lkir_progress`, `chem_dft_gpu_lkir_launch_pipeline`, `chem_dft_run_gpu_queue`, PH-SCI-GPU-18 smoke
- **Acceptance:** PH-SCI-GPU-18 `compile_open_ok`; composable `import_lig_chem_backend` checks GPU queue stub.
- **Status:** partial — CPU oracle + LKIR matmul spine reuse; vendor CUDA blob parity still stub.

## Studio / MCP hook

`studio_mcp_chem_dft_run` dispatch remains drug-LitL energy check; queued GPU path is wired via `chem_dft_run_gpu_queue()` in composable `import_lig_chem_backend.li` (full Studio import deferred).

## Competitive benchmark (Layer B)

Honest comparison vs **PySCF** (primary OSS oracle) and optional **Psi4**; **ORCA** documented as user-run external oracle only (not redistributable in CI).

```bash
pip install --user --break-system-packages -r scripts/requirements-ph-sci-chem-dft-competitive.txt
bash scripts/bench-ph-sci-chem-dft-competitive.sh
bash scripts/ph-sci-chem-dft-competitive-gates.sh   # CI-friendly gate
```

- Registry: `benchmarks/competitive/ph-sci-chem-dft.toml`
- Results: `benchmarks/results/ph-sci-chem-dft-competitive.json`
- Docs: `benchmarks/competitive/README-chem-dft.md`

**Parity expectation:** Li mini radial-grid scaffold ≠ PySCF Gaussian-basis SCF — large `energy_delta_hartree` is expected until CHEM-04+ full DFT; timing `ratio_vs_li` still reported.

## CI

```bash
# WSL from lic repo root
bash scripts/ph-sci-gpu-chem-gates.sh
# or
bash scripts/check-science-gpu-gate.sh
```

## science_gpu IDs

| ID | Test | Package |
|----|------|---------|
| PH-SCI-GPU-16 | `chem_gpu_dft_energy.li` | li-chem |
| PH-SCI-GPU-17 | `drug_gpu_dft_stage.li` | li-sim-drug-design |
| PH-SCI-GPU-18 | `chem_gpu_dft_lkir.li` | li-chem |

Existing PH-SCI-GPU-06 (combustion) and PH-SCI-GPU-15 (LitL workflow) remain; DFT is additive.

| PH-SCI-GPU-19 | `echem_gpu_che_h_ads.li` | li-chem (WP-ECHEM-01) |

See [ph-sci-electrochemistry-sim-plan.md](ph-sci-electrochemistry-sim-plan.md) for CHE/SHE/EDL/NEB roadmap and PySCF electrochemistry oracle (WP-ECHEM-02).

## Still stub (vendor CUDA)

- Dedicated LKIR kernel for `chem_dft_energy_from_density` grid loops (today reuses `lig_kernel_matmul_f32` spine).
- Device-buffer readback parity vs CPU oracle (requires `LIG_EMIT_CUDA=1` + vendor pilot WP-SCI-GPU-VENDOR-01).
- Full off-diagonal Fock / generalized eigenproblem (overlap metric `S` built but not yet used in eigensolve).
