# MPI → li-parallel migration

<!-- DOC-PAR-07 -->

Map MPI rank/world and collectives to Li distributed runtime. v1 uses env bootstrap; programmed `hosts=[...]` blocks land in WP-PAR-20.

## Rank and size

| MPI | Li |
|-----|-----|
| `MPI_Comm_rank(comm, &rank)` | `rank()` or `LI_DPAR_RANK` |
| `MPI_Comm_size(comm, &size)` | `world_size()` or `LI_DPAR_WORLD_SIZE` |
| `MPI_Init` / `MPI_Finalize` | `lipar-run.sh` launcher |

```li
import parallel.distributed

def main() -> int raises IO
  requires true
  ensures true
  decreases 0
=
  var r: int = rank()
  var w: int = world_size()
  return 0
```

## Block partition

| MPI | Li |
|-----|-----|
| Manual `start = rank * N / size` | `block_partition_begin(N, rank(), world_size())` |
| Manual `end = (rank+1) * N / size` | `block_partition_end(N, rank(), world_size())` |

```li
distributed for i in 0..<N
  requires true
  decreases N - i
=
  local[i] = compute(rank(), i)
```

## Collectives

| MPI | Li v1 | Status |
|-----|-------|--------|
| `MPI_Bcast` | `bcast` (ring) | **Implemented** |
| `MPI_Allreduce` | `allreduce` (ring pairwise) | **Implemented** |
| `MPI_Barrier` | `barrier()` | **Partial** |
| `MPI_Scatter` / `MPI_Gather` | — | **Pending** (WP-PAR-22) |
| `MPI_Scan` | — | **Pending** (WP-PAR-22) |

## Launch

```bash
# 4 ranks on localhost (env bootstrap)
LI_DPAR_WORLD_SIZE=4 LI_DPAR_RANK=0 ./app &
LI_DPAR_WORLD_SIZE=4 LI_DPAR_RANK=1 ./app &
# … or use lipar-run.sh
packages/li-parallel/scripts/lipar-run.sh -n 4 ./app
```

## Ghost exchange

For stencil halos, use `parallel/ghost.li` helpers. Full overlap comm is **pending** (WP-PAR-70–72).
