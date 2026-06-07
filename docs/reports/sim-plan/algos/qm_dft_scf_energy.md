# qm_dft_scf_energy (algo 418) — sim plan report

**Date:** 2026-06-07  
**Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**Todo:** `sim-p2-qm-dft-scf`  
**north_star_fit:** PH-SCI, PH-5b, G-math — proof-first SCF stub honesty

---

## Validity

| Tier | Surface | Status |
|------|---------|--------|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_energy()` | Proved mini SCF scaffold |
| T1 | `li-chem` `echem_dft_h2_energy_hartree()` | Dispatch checksum for algo 418 |
| T2 | PySCF `pyscf_sto3g_h2_energy.py` | Optional external oracle |

## Oracle tiers

| Check | Criterion |
|-------|-----------|
| Stub honesty | `run_algo(418)` checksum **≠ 1.001** |
| Energy sign | `total_energy_hartree < 0` |
| Convergence | SCF scaffold converges within 8 iterations |
| Summary | `li_sim_summary_v1` QM keys present |

## Repro

```bash
./scripts/bench-package.sh li-sim-scientific
./scripts/bench-package.sh li-physics-quantum
lic build li-tests/composable/import_chem_dft_smoke.li
```

## Deferred

- Full Gaussian integral chain (401–404)
- Native RKS performance / dashboard timing green
- `threshold_ratio_cpp` relaxation
