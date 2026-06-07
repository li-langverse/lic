# qm_dft_scf_energy — minimal SCF stub (algo_id=418)

**Todo:** `sim-p2-qm-dft-scf` · **Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**Registry algo:** `qm_dft_scf_energy` (id=418)  
**Status:** `implemented_smoke: true` — honest SCF energy checksum (not 1.001)

## Problem

`run_algo(algo_qm_dft_scf_energy())` routed through `run_algo_registry_stub` with checksum **1.001**. Tier-2 smoke explicitly required stub honesty. No `li_sim_summary_v1` QM metrics.

## Fix (2026-06-07)

1. **`packages/li-physics-quantum`** — `qm_scf_h2_stub_energy()` H₂ STO-3G-class radial SCF scaffold (T0 kernel).
2. **`packages/li-sim-scientific`** — `sim_scientific_oracle_checksum_qm_dft_scf()` + `run_qm_dft_scf_tier2_registry()` dispatch; uses `echem_dft_h2_energy_hartree()` (T1) and kernel energy.
3. **Smokes** — `qm_dft_scf_interface_smoke.li`, `run_algo_registry_tier2.li` (reject 1.001), `import_chem_dft_smoke.li` composable.
4. **Summary** — `benchmarks/results/li_runs/qm_dft_scf_energy.li.summary.min.json` with QM keys.

## Oracle tiers

| Tier | Surface | CI default |
|------|---------|------------|
| T0 | `physics.quantum` `qm_scf_h2_stub_energy` | Always |
| T1 | `chem` `echem_dft_h2_energy_hartree` | Always |
| T2 | PySCF subprocess | Optional `chem-external-oracle` profile |

## Validity

- Checksum **≠ 1.001**; finite negative `total_energy_hartree`
- `verticals.toml` `qm_dft` remains `workload_class=stub` until external oracle column green
