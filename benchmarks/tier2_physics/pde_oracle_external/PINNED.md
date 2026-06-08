# Pinned external oracle builds (pde-r1)

Align with [lic#33](https://github.com/li-langverse/lic/issues/33) numerics pin policy — no floating distro packages in CI truth tables.

| Dependency | Pin | Notes |
|------------|-----|-------|
| PETSc | **3.25.x** | SNES/KSP stack; configure with hypre |
| hypre | **2.32.x** | `PCHYPRE` + `boomeramg` for T2 CPU oracle |
| MPI | OpenMPI 4.x or MPICH | Single-rank default for T2 |
| Kokkos | PETSc `--with-kokkos` | T2b `PCBJKOKKOS` only — deferred (lic#28) |

**Reference options (CPU):**

```
-pc_type hypre
-pc_hypre_type boomeramg
-ksp_type cg
-snes_type ksponly
```
