# API reference — distributed

<!-- DOC-PAR-04 -->

Distributed runtime: `runtime/li_dpar.c`. Package wrappers: `parallel/distributed.li`.

## Environment bootstrap

| Variable | Role |
|----------|------|
| `LI_DPAR_RANK` | 0-based rank |
| `LI_DPAR_WORLD_SIZE` | Process count |
| `LI_DPAR_HOSTS` | Comma-separated host list |

Launch helper: `packages/li-parallel/scripts/lipar-run.sh`.

## Package API

| Function | Role |
|----------|------|
| `rank()` | Current rank |
| `world_size()` | Process count |
| `barrier()` | Global barrier |
| `scatter_f64(sendbuf, recvbuf, sendcount, root)` | Root scatters equal slices (WP-PAR-22) |
| `gather_f64(sendbuf, recvbuf, sendcount, root)` | Root gathers equal slices (WP-PAR-22) |
| `scan_sum_f64(local, out)` | Exclusive prefix sum (WP-PAR-22) |
| `block_partition_begin(global_n, rank, world)` | Local range start |
| `block_partition_end(global_n, rank, world)` | Local range end (exclusive) |

## Compiler surface

```li
distributed for i in 0..<N
  requires true
  decreases N - i
=
  local_buf[i] = compute(rank(), i)
```

## Collectives (v1)

| Collective | Status |
|------------|--------|
| `bcast` | **Implemented** (ring) |
| `allreduce` | **Implemented** (ring pairwise) |
| `scatter` / `gather` | **Implemented** (root hub, WP-PAR-22) |
| `scan` | **Implemented** (gather + prefix scatter, WP-PAR-22) |
| `barrier` | **Implemented** |

## Status

Env-rank bootstrap is **implemented**. Programmed `hosts=[...]` cluster blocks are **pending** (WP-PAR-20).
