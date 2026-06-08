# sim-plan — `qm_dft_scf_energy` (algo_id=418)

**Status:** implemented smoke (sim-p2-qm-dft-scf)  
**Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**PH ids:** PH-SCI, PH-5b, PH-QM · **G ids:** G-math

## Validity

| Tier | Surface | Role | CI default |
|------|---------|------|------------|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_energy()` | Proved H₂ mini SCF kernel | Always |
| T1 | `li-chem` `echem_dft_h2_energy_hartree()` | User API / dispatch checksum | Always |
| T2 | PySCF subprocess (`pyscf_sto3g_h2_energy.py`) | External Ha oracle column | Optional profile `chem-external-oracle` |

**Reference geometry:** H₂ bond 0.74 Å, basis STO-3G, method RKS/LDA.

## Dispatch

- `li-sim-scientific`: `run_qm_dft_scf_tier2_registry` replaces checksum **1.001** stub.
- `vertical_qm_dft()` routes to `algo_qm_dft_scf_energy()` (418).

## Summary contract (`li_sim_summary_v1`)

| Key | Value |
|-----|-------|
| `metrics.total_energy_hartree` | negative float from SCF scaffold |
| `metrics.converged` | true |
| `metrics.scf_iterations` | 8 |
| `metrics.method` | RKS/LDA |
| `metrics.basis` | STO-3G |

## Tests

- `packages/li-sim-scientific/li-tests/smoke/qm_dft_scf_interface_smoke.li`
- `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li`
- `packages/li-physics-quantum/li-tests/smoke/qm_scf_h2_stub_smoke.li`
- `li-tests/composable/import_chem_dft_smoke.li`

## Gates

```bash
cd lic
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
```
