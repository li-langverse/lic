# qm_dft_scf_energy (algo_id=418)

**Status:** implemented smoke (sim-p2, lic#478)  
**Vertical:** `qm_dft`  
**Kernel:** `li-physics-quantum` → `qm_scf_h2_stub_energy()`  
**Dispatch:** `li-sim-scientific` → `run_qm_dft_scf_tier2_registry()`

## Validity

| Tier | Oracle | Role |
|------|--------|------|
| T0 | `qm_scf_h2_stub_energy()` (Li proved scaffold) | Default CI — checksum ≠ 1.001 |
| T1 | `echem_dft_h2_energy_hartree()` (`li-chem`) | User API cross-link |
| T2 | `pyscf_sto3g_h2_energy.py` (optional profile) | External Ha reference |

**Geometry:** H₂ bond 0.74 Å, basis STO-3G, method RKS/LDA (registry row 418).

## Gates

```bash
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
./li-tests/run_all.sh composable  # import_chem_dft_smoke.li
```

## Summary contract (`li_sim_summary_v1`)

QM keys: `total_energy_hartree`, `converged`, `scf_iterations`, `method`, `basis`.

See `benchmarks/results/qm_dft_scf_energy/li.summary.min.json`.
