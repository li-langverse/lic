# qm_dft_scf_energy — H2 STO-3G LDA SCF stub (algo_id=418)

**Todo:** `sim-p2-qm-dft-scf`  
**Package:** `li-physics-quantum` (`import physics.quantum`)  
**Registry algo:** `qm_dft_scf_energy` (id=418)  
**Status:** `implemented_smoke: true` (composable + `run_algo` dispatch)

## Slice (2026-06-07)

1. **`packages/li-physics-quantum/src/lib.li`** — `QmDftScfStubResult`, `qm_dft_scf_h2_lda_stub()`, `qm_dft_scf_energy_smoke_checksum()`.
2. **`packages/li-sim-scientific/src/lib.li`** — `run_qm_dft_scf_energy_smoke`, `run_qm_dft_scf_tier2_registry` for algo_id=418 (replaces registry stub 1.001).
3. **`benchmarks/harness/sim_summary.py`** — QM summary metrics (`total_energy_hartree`, `scf_iterations`, `converged`, `method`, `basis`).
4. **`li-tests/composable/import_physics_quantum_qm_dft_scf.li`** — Package composable gate.
5. **`li-tests/composable/import_chem_dft_smoke.li`** — chem-r2 cross-link smoke.

## Validity

| Check | Result |
|-------|--------|
| Composable `import_physics_quantum_qm_dft_scf.li` | **ok** |
| `qm_dft_scf_interface_smoke.li` | **ok** |
| Registry `implemented_smoke` | **true** (id=418) |

```bash
export LIC_ROOT=$PWD
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
```

## Follow-ups

- Replace tabulated 2×2 stub with AO integral chain (401–404) + Psi4 subprocess oracle (H₂ STO-3G).
- Tier-2 harness row `benchmarks/tier2_physics/qm_dft_scf_energy/` when native kernel diverges from schrodinger template.
