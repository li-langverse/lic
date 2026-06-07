# API reference — shared memory

<!-- DOC-PAR-03 -->

Runtime symbols live in `runtime/li_par_pool.c` and `runtime/li_par_reduce.c`. Compiler lowering: `parallel for`, `reduce(+|min|max: var)`.

## Compiler surface

```li
parallel for i in 0..<N
  requires disjoint_elem(i, buf)
  decreases N - i
=
  buf[i] = compute(i)
```

| Flag / env | Effect |
|------------|--------|
| `--cores=N` | Thread pool size |
| `LI_PARALLEL=1` | Enable parallel runtime at exec |
| `LI_PAR_SCHEDULE` | `static` \| `dynamic` \| `guided` \| `steal` |

## C runtime (selected)

| Symbol | Role |
|--------|------|
| `li_par_pool_init` | Create persistent pool |
| `li_par_pool_parallel_for` | Execute outlined body |
| `li_par_pool_set_schedule` | Select scheduler |
| `li_par_reduce_sum_f64` | Tree reduction over `f64` tiles |

## Package proof helpers

See `parallel/proof.li`:

| Function | Role |
|----------|------|
| `disjoint_tile(tile, tiles)` | Tile index in range |
| `disjoint_block(row, col, stride)` | Block disjointness stub |
| `reduce_tile_disjoint(tile, tiles)` | Reduction tile policy |

## Status

| Feature | Status |
|---------|--------|
| Persistent pool | **Implemented** |
| Work-stealing | **Implemented** |
| `reduce` on `parallel for` | **Implemented** — sum/min/max + team-scoped reduce |
| `team()` / scoped cores | **Implemented** — push/pop stack, `cores=0` auto-inherit (WP-PAR-17–19) |
