# qm_dft_scf_energy (algo_id=418)

**Status:** implemented smoke (WP-SIM-P2 / lic#478)  
**Vertical:** `qm_dft` (id 4)  
**Package kernel:** `li-physics-quantum` → `qm_scf_h2_stub_energy()`  
**Dispatch:** `li-sim-scientific` → `run_qm_dft_scf_tier2_registry()`

## Validity

| Tier | Surface | Role |
|------|---------|------|
| T0 | `physics.quantum` H₂ mini SCF scaffold | Proved negative Ha energy + `converged` flag |
| T1 | `chem.echem_dft_h2_energy_hartree()` | chem-r2 user API cross-link (composable smoke) |
| T2 | PySCF subprocess oracle | Optional external column (not CI default) |

**Reference geometry:** H₂ bond 0.74 Å, basis STO-3G class, method RKS/LDA.

**Honesty gate:** tier-2 smoke rejects checksum **1.001**; `run_algo(algo_qm_dft_scf_energy())` returns finite negative `total_energy_hartree`.

## Tests

- `packages/li-sim-scientific/li-tests/smoke/qm_dft_scf_interface_smoke.li`
- `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li` (418 row)
- `li-tests/composable/import_qm_dft_scf_smoke.li`

## Summary contract

See `benchmarks/results/qm_dft_scf_energy/li.summary.min.json` — `li_sim_summary_v1` with QM keys:
`total_energy_hartree`, `converged`, `scf_iterations`, `method`, `basis`.
