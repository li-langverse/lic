# PDE implicit competitive benchmark (PETSc + hypre)

Compare **Li `pde_implicit_jacobi_oracle_checksum()`** (8-cell Jacobi scaffold) against optional **PETSc + hypre** reference builds for catalog row `pde_heat_implicit_jacobi` (algo_id 204).

## Run

```bash
bash scripts/ph-sci-pde-implicit-competitive-gates.sh
# or bench only:
bash scripts/bench-ph-sci-pde-implicit-competitive.sh
```

Output: `benchmarks/results/ph-sci-pde-implicit-competitive.json`

## Methodology

| Field | Value |
|-------|-------|
| PDE | 1D heat equation, backward Euler implicit step |
| Discretization | 8 interior cells, Dirichlet ends |
| Linear solve | Jacobi iterations (Li); KSP+hypre BoomerAMG (vendor stub) |
| Li kernel | `physics.fluids.pde_implicit_jacobi_oracle_checksum` |
| Checksum | Sum of field values after 200 steps × 4 Jacobi iters/step |

## Vendor pin policy (lic#33)

Pinned in `benchmarks/competitive/ph-sci-pde-implicit.toml`:

| Package | Pin | Notes |
|---------|-----|-------|
| PETSc | **3.25.0** | `PETSC_DIR` user install; PCBJKOKKOS GPU PC documented |
| hypre | **2.32.0** | Via PETSc externalpackages or `HYPRE_DIR` |

## License notes

- **PETSc** — BSD-2; not redistributed in CI.
- **hypre** — Apache-2.0 / LGPL-2.1; not redistributed in CI.
- **Li Jacobi** — always runs; energy/checksum from Python mirror when `lic` binary absent.

## Expected parity gaps

Li 8-cell Jacobi is a **scaffold**, not 64×64 tier-2 C parity. `parity_gate_pass` uses loose tolerance until B1 PETSc driver lands. Timing `ratio_vs_li` is reported when both sides execute.

## Files

| Path | Role |
|------|------|
| `docs/numerics/implicit-pde-petsc-hypre-plan.md` | Stack + API plan (lic#108) |
| `benchmarks/competitive/ph-sci-pde-implicit.toml` | Registry + version pins |
| `benchmarks/competitive/pde_implicit_oracle.toml` | Oracle metadata |
| `benchmarks/competitive/pde_implicit_competitive_common.py` | Shared workload + Li mirror |
| `benchmarks/competitive/petsc_heat_implicit_stub.py` | PETSc skip/stub driver |
| `scripts/bench-ph-sci-pde-implicit-competitive.sh` | Orchestrator |
| `scripts/ph-sci-pde-implicit-competitive-gates.sh` | CI gate |
