# lic#129 Phase 1 — MPI×threads occupancy guard

**Date:** 2026-06-07  
**Issue:** [lic#129](https://github.com/li-langverse/lic/issues/129)  
**PH / G:** PH-7e, G-par (diagnostic-only)

## Summary

Adds a one-shot stderr warning when `mpi_ranks × parallel_team` exceeds detected physical cores, plus normative docs for OpenMP affinity and hybrid MPI+OpenMP sizing.

## Changes

- `runtime/li_par_pool.c` — `li_warn_occupancy_once()` before first `li_parallel_for_i64`; reads `OMPI_COMM_WORLD_SIZE` / `PMI_SIZE`; `LI_EXEC_WARN_OVERSUBSCRIBE=0` disables
- `docs/superpowers/specs/2026-06-07-li-openmp-affinity-occupancy-rubric.md` — normative rubric
- `docs/language/parallelism.md` — affinity + hybrid MPI section
- `li-tests/execution_occupancy/` — smoke harness

## Deferred (later phases)

- OpenMP affinity defaults (`openmp_prescriptive` backend, #34 gate)
- `--parallel-backend` CLI / `[execution]` manifest parse (#129 Phase 3)
- Benchmarks `execution_resource_sweep` occupancy columns (benchmarks repo)

## Verification

```bash
./scripts/build.sh
./li-tests/run_all.sh execution_occupancy
```
