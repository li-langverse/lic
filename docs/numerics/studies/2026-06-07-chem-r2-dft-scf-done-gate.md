# chem-r2 done gate — `qm_dft_scf_energy` (algo 418)

**Date:** 2026-06-07  
**Todo:** `sim-p2-qm-dft-scf` · **Issue:** [#478](https://github.com/li-langverse/lic/issues/478)  
**North star fit:** PH-5b (proved numerics), PH-SCI / G-math (QM surface honesty)

---

## Executive summary

- **Done gate defined** for algo **418** (`qm_dft_scf_energy`): Li H₂ STO-3G mini SCF scaffold checksum + PySCF subprocess oracle.
- **Li dispatch:** `run_qm_dft_scf_tier2_registry` replaces registry stub **1.001** with `echem_dft_h2_energy_hartree()` from `li-chem`.
- **Kernel stub:** `qm_scf_h2_stub_energy()` in `li-physics-quantum` with convergence contracts.
- **Composable gate:** `li-tests/composable/import_chem_dft_smoke.li`.
- **External oracle:** `benchmarks/competitive/pyscf_sto3g_h2_energy.py` (Apache-2.0 PySCF RKS/LDA H₂ STO-3G).

---

## Definition of Done

| Gate | Criterion | Evidence path |
|------|-----------|---------------|
| **Harness** | `run_algo(algo_qm_dft_scf_energy(), detail)` returns `checksum != 1.001` | `qm_dft_scf_interface_smoke.li` |
| **Vertical route** | `run_simulation(vertical_qm_dft(), detail)` dispatches to 418 oracle | same smoke |
| **Registry tier-2** | `run_algo_registry_tier2.li` asserts 418 checksum matches oracle | tier-2 smoke |
| **Composable** | `lic build li-tests/composable/import_chem_dft_smoke.li` succeeds | `li-tests/manifest.toml` |
| **Summary** | `li_sim_summary_v1` QM keys in `benchmarks/results/qm_dft_scf_energy/` | `validate-sim-summary.sh` |

---

## Repro commands

```bash
./scripts/bench-package.sh li-sim-scientific
./scripts/bench-package.sh li-physics-quantum
lic build li-tests/composable/import_chem_dft_smoke.li
./scripts/validate-sim-summary.sh
```
