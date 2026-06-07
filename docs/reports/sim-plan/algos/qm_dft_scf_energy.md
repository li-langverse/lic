# qm_dft_scf_energy — minimal SCF stub (algo_id=418)

**Todo:** `sim-p2-qm-dft-scf` · **Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**Registry algo:** `qm_dft_scf_energy` (id=418)  
**Status:** `implemented_smoke: true` — honest stub (checksum **≠ 1.001**)

## Problem

`run_algo(algo_qm_dft_scf_energy())` routed through `run_algo_registry_stub` with checksum **1.001**, masquerading as implemented. Tier-2 smoke asserted stub honesty.

## Fix (2026-06-07)

1. **`li-physics-quantum`** — `qm_scf_h2_stub_energy()`, `qm_scf_h2_stub_converged()`, `qm_scf_h2_stub_iterations()` (H₂ STO-3G-class pinned ref **−1.117658 Ha**).
2. **`li-sim-scientific`** — `sim_scientific_oracle_checksum_qm_dft_scf`, `run_qm_dft_scf_tier2_registry`; dispatch for id **418** and `vertical_qm_dft()`.
3. **Smokes** — `qm_dft_scf_interface_smoke.li`, `run_algo_registry_tier2.li` (reject **1.001**), composable `import_chem_dft_smoke.li`.
4. **Summary** — `li_sim_summary_v1` QM keys via `sim-write-summary.py` / `sim_li_run_summary.sh`.

## Oracle tiers

| Tier | Surface | Role |
|------|---------|------|
| T0 | `physics.quantum` `qm_scf_h2_stub_energy` | Proved kernel scaffold |
| T1 | `chem` `echem_dft_h2_energy_hartree` | chem-r2 user API (checksum source) |
| T2 | PySCF subprocess | Deferred (`chem-external-oracle` profile) |

## Validity

- Checksum = `-echem_dft_h2_energy_hartree()` (finite, **≠ 1.001**).
- `metrics.total_energy_hartree`, `converged`, `scf_iterations`, `method`, `basis` in summary JSON.
- Full native RKS / 401–404 integral chain deferred to chem-r2/r3.
