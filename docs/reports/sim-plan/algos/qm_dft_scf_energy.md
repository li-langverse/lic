# sim-plan algo report — `qm_dft_scf_energy` (418)

**Status:** implemented (sim-p2-qm-dft-scf)  
**Issue:** [#478](https://github.com/li-langverse/lic/issues/478)  
**North star fit:** PH-SCI, PH-5b, PH-QM — proof-first SCF stub honesty

---

## Validity

| Tier | Surface | Role |
|------|---------|------|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_*` | Proved microkernel (energy, converged, iterations) |
| T1 | `li-chem` `echem_dft_h2_energy_hartree()` | User API / SCF scaffold |
| T2 | `pyscf_sto3g_h2_energy.py` | Optional external Ha oracle |

Li dispatch: `run_qm_dft_scf_tier2_registry` replaces registry stub checksum **1.001**.

## Summary metrics (`li_sim_summary_v1`)

| Key | Value (v1) |
|-----|------------|
| `metrics.total_energy_hartree` | from `echem_dft_h2_energy_hartree()` |
| `metrics.converged` | true (SCF scaffold) |
| `metrics.scf_iterations` | ≤ 8 |
| `metrics.method` | RKS/LDA |
| `metrics.basis` | STO-3G |

## Tests

- `packages/li-sim-scientific/li-tests/smoke/qm_dft_scf_interface_smoke.li`
- `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li`
- `li-tests/composable/import_chem_dft_smoke.li`
- `packages/li-physics-quantum/li-tests/smoke/qm_scf_h2_stub.li`

## Deferred

- Integral chain 401–404 (full Gaussian ERIs)
- Native RKS perf / dashboard `threshold_ratio_cpp` green
- Post-HF rows 422–425
