# qm_dft_scf_energy — minimal SCF stub (algo_id=418)

**Todo:** `sim-p2-qm-dft-scf` · **Issue:** [lic#478](https://github.com/li-langverse/lic/issues/478)  
**Bench:** `qm_dft_scf_energy` (tier-2 physics / QM vertical)  
**Registry algo:** `qm_dft_scf_energy` (id=418)  
**Status:** `implemented_smoke: true` (composable + package smoke)

## Problem

`run_algo(algo_qm_dft_scf_energy())` routed through `run_algo_registry_stub` and returned checksum **1.001** — registry wiring without SCF energy honesty. Tier-2 smoke explicitly asserted the stub checksum.

## Fix (2026-06-07)

1. **`packages/li-sim-scientific/src/lib.li`** — `sim_scientific_oracle_checksum_qm_dft_scf()` calls `echem_dft_h2_energy_hartree()` (H₂ STO-3G mini SCF in `li-chem`); `run_qm_dft_scf_tier2_registry` replaces stub for id **418**.
2. **Smokes** — `qm_dft_scf_interface_smoke.li`, updated `run_algo_registry_tier2.li`, composable `import_chem_dft_smoke.li`.
3. **Summary** — `benchmarks/results/li_runs/qm_dft_scf_energy.li.summary.min.json` with QM contract keys.
4. **External oracle (optional)** — `benchmarks/competitive/pyscf_sto3g_h2_energy.py` (PySCF RKS/LDA H₂ STO-3G).

## Oracle tiers

| Tier | Surface | Role |
|------|---------|------|
| T0 | `li-chem` `echem_dft_h2_energy_hartree()` | Proved mini-basis SCF scaffold (CI default) |
| T1 | `sim.scientific` dispatch | Registry + vertical checksum parity |
| T2 | PySCF subprocess | External Ha reference column (optional profile) |

## Validity

- Checksum **≠ 1.001**; negative Hartree energy from converged SCF scaffold.
- Reference geometry: H₂ bond **0.74 Å**, basis **STO-3G**, method **RKS/LDA**.
- Package placement: DFT kernels in **`li-chem`** per chem-r3 ADR; `li-physics-quantum` remains TDSE/normalize (not DFT v1).

## Deferred

- Native RKS integral chain (401–404) before production DFT perf claims.
- `verticals.toml` `qm_dft` workload_class flip pending benchmarks ingest (#179).
