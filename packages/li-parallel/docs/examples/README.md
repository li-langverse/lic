# li-parallel examples corpus

<!-- DOC-PAR-08 -->

Worked specimens for shared-memory, distributed, and dual-mode benchmarks.

## Shared-memory codegen

| Specimen | Path |
|----------|------|
| `par_sum` reduction | `li-tests/parallel_codegen/par_sum_f64.li` |
| `parallel for reduce` | `li-tests/parallel_codegen/par_for_reduce_f64.li` |
| Race policy (must fail) | `li-tests/race_shared_memory/` |
| Good disjoint loop | `li-tests/race_shared_memory/good_disjoint_parallel.li` |

## Distributed codegen

| Specimen | Path |
|----------|------|
| `distributed for` range | `li-tests/parallel_codegen/dpar_for_range.li` |
| DPAR smoke | `li-tests/tooling/li_dpar_for_smoke.sh` |

## Package smokes

| Specimen | Path |
|----------|------|
| Kernels + ghost | `packages/li-parallel/li-tests/smoke/kernels_ghost.li` |
| Package build | `packages/li-parallel/li-tests/smoke/builds.li` |

## Benchmark dual-mode (Class A)

| Benchmark | Tier | Serial | Parallel |
|-----------|------|--------|----------|
| `matmul_blocked` | 1 | `benchmarks/tier1_linalg/matmul_blocked/li/` | same + `LI_PARALLEL=1` |
| `reduce_sum` | 1 | `benchmarks/tier1_linalg/reduce_sum/li/` | same + `LI_PARALLEL=1` |
| `simd_dot` | 1 | `benchmarks/tier1_linalg/simd_dot/li/` | same + `LI_PARALLEL=1` |
| `md_lennard_jones` | 2 | `benchmarks/tier2_physics/md_lennard_jones/li/` | same + `LI_PARALLEL=1` |

Run gate slice:

```bash
packages/li-parallel/scripts/lipar-suite.sh --profile pr --dual-mode --cores 8
```

## Run smokes

```bash
./li-tests/tooling/li_par_pool_smoke.sh
./li-tests/tooling/li_par_reduce_sum_smoke.sh
./li-tests/tooling/li_dpar_for_smoke.sh
```
