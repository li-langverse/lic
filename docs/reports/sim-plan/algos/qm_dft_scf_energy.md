# sim-plan algo report — `qm_dft_scf_energy` (418)

**Status:** implemented (sim-p2-qm-dft-scf)  
**Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**Package:** `li-sim-scientific` → `li-chem` (`echem_dft_h2_energy_hartree`)  
**PH:** PH-SCI, PH-5b, PH-QM

---

## Validity

| Tier | Surface | Role |
|------|---------|------|
| T0 | `physics.quantum` `qm_scf_h2_stub_*` | Proved reference-band stub (honest tier label) |
| T1 | `chem` `echem_dft_h2_energy_hartree()` | Mini STO-3G SCF scaffold (dispatch checksum) |
| T2 | `pyscf_sto3g_h2_energy.py` | Optional external Ha oracle |

`run_algo(418)` returns **ok=1** with checksum **≠ 1.001** (converged H₂ SCF energy in Hartree).

## Oracle tiers

- **Li dispatch:** `sim_scientific_oracle_checksum_qm_dft_scf()` → `echem_dft_h2_energy_hartree()`
- **Geometry:** H₂ bond 0.74 Å, basis STO-3G, method RKS/LDA (catalog row 418)
- **Perf:** deferred until harness timing row is non-stub (`size_label` may remain `harness pending`)

## Smokes

| Test | Path |
|------|------|
| Registry tier-2 | `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li` |
| Interface | `packages/li-sim-scientific/li-tests/smoke/qm_dft_scf_interface_smoke.li` |
| Composable | `li-tests/composable/import_chem_dft_smoke.li` |

## Summary contract (`li_sim_summary_v1`)

QM keys: `total_energy_hartree`, `converged`, `scf_iterations`, `method`, `basis` — see fixture under `benchmarks/results/qm_dft_scf_energy/`.
