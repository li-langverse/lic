# qm_dft_scf_energy — sim-p2 minimal SCF stub (algo 418)

**Todo:** `sim-p2-qm-dft-scf` · **Issue:** [#478](https://github.com/li-langverse/lic/issues/478)  
**Registry algo:** `qm_dft_scf_energy` (id=418)  
**Status:** `implemented_smoke: true` (composable + tier-2 dispatch)

## Problem

`run_algo_registry_stub` returned checksum **1.001** for all QM registry ids (401–432). The sim plan loop todo `sim-p2-qm-dft-scf` required a minimal proved SCF scaffold with honest summary metrics before perf claims.

## Fix

1. **`packages/li-sim-scientific/src/lib.li`** — `sim_scientific_oracle_checksum_qm_dft_scf()` wraps `echem_dft_h2_energy_hartree()` from `li-chem`; `run_qm_dft_scf_tier2_registry` replaces stub for id 418.
2. **Smokes** — `qm_dft_scf_interface_smoke.li`, updated `run_algo_registry_tier2.li`; composable `import_chem_dft_smoke.li`.
3. **Oracle (optional)** — `benchmarks/competitive/pyscf_sto3g_h2_energy.py` (PySCF RKS/LDA H₂ STO-3G).

## Validity

| Axis | v1 criterion |
|------|--------------|
| Validity | H₂ SCF energy `< 0` Ha; Li checksum matches oracle |
| Stability | SCF scaffold converges within 8 iterations |
| Accuracy | PySCF oracle documents reference; full Gaussian parity deferred |
| Performance | **Deferred** — no dashboard timing until 401–404 integrals |

## Package placement

Per chem-r3 ADR: DFT/SCF kernels live in **`li-chem`**; `li-physics-quantum` retains 1D TDSE hooks only.

## Repro

```bash
./scripts/bench-package.sh li-sim-scientific
lic build li-tests/composable/import_chem_dft_smoke.li
python3 benchmarks/competitive/pyscf_sto3g_h2_energy.py  # optional
```
