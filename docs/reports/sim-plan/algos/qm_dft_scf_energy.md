# qm_dft_scf_energy (algo_id=418)

**Status:** implemented smoke (sim-p2)  
**Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**north_star_fit:** PH-SCI · PH-5b · G-math — proof-first SCF stub honesty

## Validity

| Tier | Surface | Role |
|------|---------|------|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_energy()` | Proved H₂-class mini SCF scaffold |
| T1 | `li-chem` `echem_dft_h2_energy_hartree()` | Dispatch oracle for algo 418 |
| T2 | `pyscf_sto3g_h2_energy.py` | Optional external Ha column (chem-external-oracle profile) |

**Geometry:** H₂ bond 0.74 Å, basis STO-3G, method RKS/LDA.

## Gates

```bash
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
./li-tests/run_all.sh composable import_chem_dft_smoke.li
```

## Oracle

- `run_algo(algo_qm_dft_scf_energy(), detail)` returns `checksum = echem_dft_h2_energy_hartree()` (≠ 1.001).
- Summary keys: `total_energy_hartree`, `converged`, `scf_iterations`, `method`, `basis`.

## Deferred

- Native RKS / integral chain 401–404 before production QC perf claims.
- Post-HF rows 422–425.
