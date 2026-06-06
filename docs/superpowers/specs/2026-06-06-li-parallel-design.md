# li-parallel design spec (normative v1 slice)

**Date:** 2026-06-06  
**Status:** Phase 0–2 foundation  
**Provability:** G-par (shared), G-par-dist (distributed partition)

## Axes (do not conflate)

| Axis | Surface | Config |
|------|---------|--------|
| SIMD | `@vectorized` | unchanged |
| Shared parallel | `parallel for`, `reduce` | `--cores`, `LI_PARALLEL=1` |
| Distributed | `distributed for`, `rank()` | `[parallel] hosts`, `lipar run` |
| Compile farm | `--jobs` | never in source |

## Shared memory v1

- Runtime: persistent pool (`li_par_pool.c`), static/dynamic/guided scheduling (`LI_PAR_SCHEDULE`, `li_par_pool_set_schedule`)
- Reductions: `li_par_reduce_sum_f64` tree API; compiler `reduce` clause → Phase 1.1
- Windows: Win32 thread pool (no serial fallback)

## Distributed v1

- Bootstrap: `LI_DPAR_RANK`, `LI_DPAR_WORLD_SIZE`, `LI_DPAR_HOSTS`, `lipar-run.sh`
- Partition: block `li_dpar_block_partition_*`
- Collectives: `bcast`, `allreduce` (ring pairwise v1)

## Benchmark mandate

Full org suite via `lipar-suite.sh --dual-mode`; dashboard columns `li_serial`, `li_parallel`, `speedup_vs_serial`.
