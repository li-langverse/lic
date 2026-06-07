# sim-plan: qm_dft_scf_energy (algo_id=418)

**Status:** implemented (sim-p2-qm-dft-scf)  
**Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**North star:** PH-SCI / PH-5b — honest SCF stub before perf claims

## Validity

| Tier | Surface | Role | CI default |
|------|---------|------|------------|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_energy()` | Proved H₂ mini SCF scaffold | Always |
| T1 | `li-chem` `echem_dft_h2_energy_hartree()` | User API SCF energy | Always |
| T2 | PySCF subprocess (`pyscf_sto3g_h2_energy.py`) | External Ha oracle column | Optional `chem-external-oracle` |

**Reference geometry:** H₂ bond 0.74 Å, basis STO-3G, method RKS/LDA.

## Dispatch

- `li-sim-scientific`: `run_qm_dft_scf_tier2_registry` replaces checksum **1.001** stub.
- Oracle: `sim_scientific_oracle_checksum_qm_dft_scf()` → `echem_dft_h2_energy_hartree()`.
- Vertical: `vertical_qm_dft()` → `run_algo(algo_qm_dft_scf_energy(), detail)`.

## Summary metrics (`li_sim_summary_v1`)

| Key | Value |
|-----|-------|
| `total_energy_hartree` | converged H₂ SCF energy (hartree) |
| `converged` | `true` when energy delta < tol |
| `scf_iterations` | iterations to convergence (≤ 8) |
| `method` | `RKS/LDA` |
| `basis` | `STO-3G` |

## Gates

```bash
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
LI_REPO_ROOT=$PWD ./li-tests/run_all.sh composable
```
