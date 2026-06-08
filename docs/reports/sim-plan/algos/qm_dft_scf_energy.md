# qm_dft_scf_energy — sim-p2-qm-dft-scf (algo_id=418)

**Todo:** `sim-p2-qm-dft-scf` · **Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**Registry algo:** `qm_dft_scf_energy` (id=418)  
**Status:** `implemented_smoke: true` (composable + tier-2 dispatch)

## Problem

`run_algo(algo_qm_dft_scf_energy(), detail)` routed through `run_algo_registry_stub` with checksum **1.001** — stub honesty violation for the QM vertical entry point.

## Fix (2026-06-07)

1. **`li-physics-quantum`** — `qm_scf_h2_stub_energy()` microkernel (H₂ STO-3G-class radial SCF scaffold).
2. **`li-sim-scientific`** — `sim_scientific_oracle_checksum_qm_dft_scf()` + `run_qm_dft_scf_tier2_registry()` dispatch via `echem_dft_h2_energy_hartree()` (li-chem).
3. **Smokes** — `qm_dft_scf_interface_smoke.li`, `import_chem_dft_smoke.li`; tier-2 registry rejects checksum **1.001**.

## Oracle tiers

| Tier | Surface | Role | CI default |
|------|---------|------|------------|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_energy` | Proved microkernel | Always |
| T1 | `li-chem` `echem_dft_h2_energy_hartree` | User API + sim dispatch checksum | Always |
| T2 | `pyscf_sto3g_h2_energy.py` | External Ha oracle column | Optional `chem-external-oracle` |

## Summary metrics (li_sim_summary_v1)

| Key | Source |
|-----|--------|
| `total_energy_hartree` | `echem_dft_h2_energy_hartree()` |
| `converged` | SCF scaffold convergence |
| `scf_iterations` | 6–8 iterations |
| `method` | `RKS/LDA` |
| `basis` | `STO-3G` |

## Gates

```bash
cd lic
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
LI_REPO_ROOT=$PWD ./li-tests/run_all.sh composable
```
