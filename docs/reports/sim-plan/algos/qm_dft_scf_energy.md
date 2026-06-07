# sim-plan report — `qm_dft_scf_energy` (algo_id=418)

**Status:** implemented smoke (2026-06-07)  
**Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**North star:** PH-SCI / PH-5b / G-math — honest SCF stub, no checksum 1.001

## Validity

| Tier | Surface | Role | CI |
|------|---------|------|-----|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_energy()` | Proved H₂-class SCF scaffold | Always |
| T1 | `li-chem` `echem_dft_h2_energy_hartree()` | User DFT API (8-iter SCF) | Always |
| T2 | `pyscf_sto3g_h2_energy.py` | External Ha oracle | Optional profile |

## Dispatch

- `run_qm_dft_scf_tier2_registry` in `li-sim-scientific` replaces `run_algo_registry_stub` for id **418**.
- Oracle checksum: `sim_scientific_oracle_checksum_qm_dft_scf()` → `qm_scf_h2_stub_energy()` (negative Hartree, ≠ 1.001).

## Summary contract (`li_sim_summary_v1`)

QM keys emitted via `scripts/sim-write-summary.py` for algo 418:

- `metrics.total_energy_hartree`
- `metrics.converged`
- `metrics.scf_iterations`
- `metrics.method` = `RKS/LDA`
- `metrics.basis` = `STO-3G`

## Gates

```bash
export BENCHMARKS_ROOT=$PWD/.cache/li-benchmarks
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
LI_REPO_ROOT=$PWD ./li-tests/run_all.sh composable import_chem_dft_smoke
```

## Defer

- Native RKS integral chain (401–404), post-HF rows 422–425, production Gaussian/ORCA parity claims.
