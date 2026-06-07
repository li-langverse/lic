# OpenMP affinity + MPI×threads occupancy rubric (normative)

**Date:** 2026-06-07  
**Issue:** [lic#129](https://github.com/li-langverse/lic/issues/129)  
**Plan:** [2026-06-07-ph7e-openmp-affinity-mpi-occupancy-rubric-129.md](../plans/2026-06-07-ph7e-openmp-affinity-mpi-occupancy-rubric-129.md)  
**Companion:** [2026-05-25-li-execution-resources.md](2026-05-25-li-execution-resources.md), [parallelism handbook](../../language/parallelism.md)  
**PH / G:** PH-7e, PH-7b, G-par (diagnostic-only; disjoint proofs unchanged)

## Rubric table

| Practice | Li deliverable | Env / CLI | Verification |
| -------- | -------------- | --------- | ------------ |
| Thread affinity | Document `OMP_PROC_BIND`, `OMP_PLACES`; optional OpenMP defaults when `parallel_backend=openmp_prescriptive` (#34 gate) | User env; future `[execution] parallel_backend` | Handbook + spec; Phase 2 opt-in smoke |
| Occupancy guard | One-shot stderr warn when `mpi_ranks × team_size > physical_cores` | `LI_EXEC_WARN_OVERSUBSCRIBE=1` (default on); `OMPI_COMM_WORLD_SIZE` / `PMI_SIZE` for ranks | `li-tests/execution_occupancy/` |
| Backend choice | `portable_pthread` (default) vs `openmp_prescriptive` vs `auto` | Future `--parallel-backend=` + `[execution]` | Phase 3 parse tests |
| Proof preserved | Guard is diagnostic only | — | `race_shared_memory`, `decorator_exploits` unchanged |

## Runtime team size

| Source | Precedence |
| ------ | ---------- |
| `lic build --threads=N` | Wins over `--cores` / `--threads-per-core` |
| `lic build --cores=N --threads-per-core=M` | Team = min(N×M, 64); `--cores` capped to host logical cores at compile time |
| Baked constant in binary | Passed as 4th arg to `li_parallel_for_i64`; 0 = host default at run time |
| `LI_OMP_THREADS` | Deprecated env fallback when build omits team flags |

## Occupancy guard (Phase 1 — shipped)

Before the first `parallel for` region executes:

1. `physical_cores` ← `_SC_NPROCESSORS_ONLN` (or Windows `GetSystemInfo`)
2. `mpi_ranks` ← `OMPI_COMM_WORLD_SIZE` or `PMI_SIZE` (default 1)
3. `team_size` ← baked build constant, or resolved host default when 0
4. If `mpi_ranks × team_size > physical_cores` and `LI_EXEC_WARN_OVERSUBSCRIBE` is not `0`, emit **once**:

```text
lic: warning: parallel team (N) × mpi_ranks (M) = T exceeds physical cores (C); see docs/language/parallelism.md#hybrid-mpi-openmp
```

The guard never changes iteration semantics, team size, or affinity — it only surfaces misconfiguration for tier-2 HPC/game physics benches.

## OpenMP affinity (Phase 2 — deferred)

When LLVM OpenMP IR lowering (#34) is selected and `[execution] parallel_backend = "openmp_prescriptive"`:

- If user has **not** set `OMP_PROC_BIND` / `OMP_PLACES`, runtime may set `OMP_PROC_BIND=spread` and `OMP_PLACES=threads` via `setenv(..., 0)` (no overwrite).
- `portable_pthread` path (current default) **never** sets affinity env.

## Related issues

- **#124** — prescriptive vs descriptive divergent branches (codegen; not this rubric)
- **#34** — LLVM OpenMP IR lowering (affinity defaults gate)
- **#116** — OpenMPTarget offload
