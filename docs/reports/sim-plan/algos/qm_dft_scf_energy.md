# qm_dft_scf_energy (algo_id=418)

**Status:** smoke implemented (sim-p2-qm-dft-scf, lic#478)  
**Vertical:** `qm_dft` (id=4)  
**Package routing:** `li-sim-scientific` → `li-chem` oracle + `li-physics-quantum` stub metrics

## Validity

| Tier | Surface | Role | CI default |
|------|---------|------|------------|
| T0 | `li-physics-quantum` `qm_scf_h2_stub_energy()` | Proved H₂-class SCF scaffold (bond 0.74 Å) | **Yes** |
| T1 | `li-chem` `echem_dft_h2_energy_hartree()` | Mini-basis SCF oracle (checksum) | **Yes** |
| T2 | PySCF subprocess | External Ha oracle column | Optional (`chem-external-oracle`) |

**Stub honesty:** `run_algo(algo_qm_dft_scf_energy())` returns `checksum = echem_dft_h2_energy_hartree()` — **not** registry placeholder `1.001`.

## Summary contract (`li_sim_summary_v1`)

| Key | Source |
|-----|--------|
| `metrics.total_energy_hartree` | `echem_dft_h2_energy_hartree()` |
| `metrics.converged` | `qm_dft_scf_stub_converged()` |
| `metrics.scf_iterations` | `qm_dft_scf_stub_iterations()` |
| `metrics.method` | `RKS/LDA` |
| `metrics.basis` | `STO-3G` |

## Smokes

- `packages/li-sim-scientific/li-tests/smoke/qm_dft_scf_interface_smoke.li`
- `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li` (418 row)
- `li-tests/composable/import_chem_dft_smoke.li`

## Repro

```bash
export LIC=build/compiler/lic/lic
./scripts/sim-plan-gates.sh
LI_SIM_ALGO_ID=418 LI_SIM_OK=1 LI_SIM_VERTICAL_ID=4 \
  python3 scripts/sim-write-summary.py --format json_min \
  -o benchmarks/results/li_runs/qm_dft_scf_energy.li.summary.min.json
```

**PH ids:** PH-SCI, PH-5b · **G ids:** G-math (numerics stub honesty)
