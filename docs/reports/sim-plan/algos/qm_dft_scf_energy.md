# qm_dft_scf_energy — H2 STO-3G LDA SCF stub (algo_id=418)

**Todo:** `sim-p2-qm-dft-scf`  
**Package:** `li-physics-quantum` (`import physics.quantum`)  
**Registry algo:** `qm_dft_scf_energy` (id=418)  
**Status:** `implemented_smoke: true` (composable + `run_algo` dispatch)

## Slice (2026-05-30)

1. **`packages/li-physics-quantum/src/lib.li`** — Added `QmDftScfStubResult`, `qm_dft_scf_h2_lda_stub()` (6-iter 2×2 Fock + density mixing), and `qm_dft_scf_energy_smoke_checksum()`.
2. **`li-tests/composable/import_physics_quantum_qm_dft_scf.li`** — Composable smoke gate for package-scoped benches.
3. **`packages/li-sim-scientific/src/lib.li`** — Wired `run_qm_dft_scf_energy_smoke` into `run_algo` for algo_id=418 (replaces registry stub).
4. **`benchmarks/harness/sim_summary.py`** — QM summary metrics (`total_energy_hartree`, `scf_iterations`, `converged`, `method`, `basis`).
5. **`li-tests/tooling/sim_li_run_summary.sh`** — Emits `qm_dft_scf_energy.li.summary.json` for algo_id=418.

## Validity

| Check | Result |
|-------|--------|
| Composable `import_physics_quantum_qm_dft_scf.li` | **ok** |
| `SIM_PLAN_PACKAGE=li-physics-quantum ./scripts/sim-plan-gates.sh` | **ok** (2026-05-30) |
| `SIM_PLAN_PACKAGE=li-sim-scientific ./scripts/sim-plan-gates.sh` | **ok** (2026-05-30) |
| Registry `implemented_smoke` | **true** (id=418) |

```bash
export LIC_ROOT=$PWD
export SIM_PLAN_PACKAGE=li-physics-quantum
./scripts/sim-plan-gates.sh
```

## Follow-ups

- Replace tabulated 2×2 stub with AO integral chain (401–404) + Psi4 subprocess oracle (H₂ STO-3G).
- Tier-2 harness row `benchmarks/tier2_physics/qm_dft_scf_energy/` when native kernel diverges from schrodinger template.
