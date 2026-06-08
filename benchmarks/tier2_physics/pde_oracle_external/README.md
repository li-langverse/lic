# PDE external oracle (PETSc + hypre)

Tier-2 implicit heat oracle column for `pde_heat_implicit_jacobi`.

| Artifact | Path |
|----------|------|
| Oracle pins | `benchmarks/competitive/pde_oracle.toml` |
| Driver | `benchmarks/harness/pde_external_oracle.py` |
| Pinned versions | `PINNED.md` |
| Plan | `docs/superpowers/plans/2026-06-07-pde-r1-hypre-petsc-oracle-plan.md` |

**Issue:** [lic#108](https://github.com/li-langverse/lic/issues/108)

## Stub run (no PETSc required)

```bash
python3 benchmarks/harness/pde_external_oracle.py --engine petsc_hypre --dry-run
./li-tests/tooling/pde_external_oracle_stub.sh
```
