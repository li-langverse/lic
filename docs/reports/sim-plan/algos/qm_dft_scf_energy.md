# qm_dft_scf_energy (algo 418) — sim-p2 validity report

**Status:** implemented smoke (2026-06-07)  
**Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**PH:** PH-SCI, PH-5b, PH-QM · **G:** G-math (stub honesty)

## Dispatch

| Surface | Path |
|---------|------|
| Kernel T0 | `li-physics-quantum` → `qm_scf_h2_stub_energy()` |
| Chem oracle T1 | `li-chem` → `echem_dft_h2_energy_hartree()` |
| Registry dispatch | `li-sim-scientific` → `run_qm_dft_scf_tier2_registry()` (algo **418**) |
| Vertical | `run_simulation(vertical_qm_dft())` → same checksum |

## Oracle tiers

| Tier | Role | CI default |
|------|------|------------|
| T0 | Proved H₂ SCF scaffold in `physics.quantum` | Yes |
| T1 | `echem_dft_h2_energy_hartree()` (RKS/LDA-class grid scaffold) | Yes |
| T2 | PySCF subprocess (`pyscf_sto3g_h2_energy.py`) | Optional profile `chem-external-oracle` |

## Honesty

- Checksum **1.001** registry stub **rejected** in `run_algo_registry_tier2.li`.
- `verticals.toml` `qm_dft` remains `workload_class=stub` until external oracle column is green.
- Full native RKS + integral chain (401–404) deferred to chem-r3.

## Tests

| Artifact | Purpose |
|----------|---------|
| `qm_scf_h2_stub_smoke.li` | T0 kernel contracts |
| `qm_dft_scf_interface_smoke.li` | Registry + vertical dispatch |
| `import_chem_dft_smoke.li` | Composable chem ↔ sim cross-link |
| `run_algo_registry_tier2.li` | Tier-2 registry gate incl. 418 |

## Summary metrics (`li_sim_summary_v1`)

Required QM keys: `total_energy_hartree`, `converged`, `scf_iterations`, `method`, `basis`.

Reference geometry: H₂ bond **0.74 Å**, basis **STO-3G**, method **RKS/LDA**.
