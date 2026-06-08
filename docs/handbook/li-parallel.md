# li-parallel handbook

<!-- DOC-PAR-01 -->

**Package:** `li-parallel` · **Design spec:** [2026-06-06-li-parallel-design](../superpowers/specs/2026-06-06-li-parallel-design.md) · **Gaps:** [gap register](../../packages/li-parallel/docs/gap-register.md)

!!! note "Provability status"
    Shared-memory `parallel for` disjointness is **partial** (**G-par**). Distributed partition helpers are a **closed slice** (**G-par-dist**). See [provability gaps](../verification/provability-gaps.md) and [proofs table](../../packages/li-parallel/docs/proofs-table.md).

## What li-parallel is

Native Li parallelism — OpenMP/MPI replacement without user-installed frameworks:

| Axis | Surface | Config |
|------|---------|--------|
| SIMD | `@vectorized` | unchanged |
| Shared parallel | `parallel for`, `reduce` | `--cores`, `LI_PARALLEL=1` |
| Distributed | `distributed for`, `rank()` | `LI_DPAR_*`, `lipar run` |
| Compile farm | `--jobs` | never in source |

## Quick start

```bash
# Shared-memory parallel build
lic build app.li -o app --cores=8
LI_PARALLEL=1 ./app

# Package selftest
lic build packages/li-parallel/src/lib.li -o li-parallel
./li-parallel
```

## Shared-memory runtime (v1)

- Persistent thread pool (`li_par_pool.c`)
- Schedulers: static, dynamic, guided, work-stealing (`LI_PAR_SCHEDULE`)
- Tree reductions: `li_par_reduce_sum_f64`; compiler `reduce(+: var)` on `parallel for`
- Windows: Win32 thread pool (no serial fallback)

See [API — shared memory](../../packages/li-parallel/docs/api-shared-memory.md).

## Distributed runtime (v1)

- Bootstrap via `LI_DPAR_RANK`, `LI_DPAR_WORLD_SIZE`, `LI_DPAR_HOSTS`
- Block partition: `block_partition_begin` / `block_partition_end`
- Collectives: `bcast`, `allreduce` (ring pairwise v1)

See [API — distributed](../../packages/li-parallel/docs/api-distributed.md).

## Benchmark dual-mode

Org suite emits `li_serial` and `li_parallel` columns:

```bash
packages/li-parallel/scripts/lipar-suite.sh --profile pr --dual-mode --cores 8
```

See [benchmark dual-mode guide](../../packages/li-parallel/docs/benchmark-dual-mode.md).

## Migration

| From | Guide |
|------|-------|
| OpenMP `#pragma omp` | [migrate-openmp](../../packages/li-parallel/docs/migrate-openmp.md) |
| MPI `MPI_*` | [migrate-mpi](../../packages/li-parallel/docs/migrate-mpi.md) |

## Examples

Worked specimens: [examples corpus](../../packages/li-parallel/docs/examples/README.md).

## Related handbook pages

- [SIMD and parallel](../language/simd-parallel.md) — language-level `parallel for`
- [Parallelism and vectorization](../language/parallelism.md) — decorator-first patterns
- [Math HPC examples](../guide/math-hpc-examples.md) — Tier 1/2 benchmarks
