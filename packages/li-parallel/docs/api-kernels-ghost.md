# API reference — kernels and ghost exchange

<!-- DOC-PAR-05 -->

Package modules: `parallel/kernels.li`, `parallel/ghost.li` (WP-PAR-31, WP-PAR-32).

## BLAS-style kernels

| Function | Role |
|----------|------|
| `par_axpy(n, a, x, y)` | `y += a * x` |
| `par_copy(n, src, dst)` | Element copy |
| `par_matmul_outer(m, n, x, y, c)` | 2×2 outer-product matmul |
| `par_outer_elem_ij(xi, yj)` | Scalar outer-product tile |

## Ghost / halo templates

| Function | Role |
|----------|------|
| `halo_width_default()` | Default halo width (1) |
| `halo_local_begin/end(global_n, rank, world)` | Local tile bounds |
| `halo_left_ghost_index(local_begin, width, slot)` | Left ghost index |
| `halo_right_ghost_index(local_end, slot)` | Right ghost index |
| `ghost_exchange_1d_left/right_sample(v)` | Serial halo copy sketch |

## Selftest

`li_parallel_selftest()` in `src/lib.li` exercises kernel and ghost helpers.

## Status

Kernels are **implemented** (serial v1). Ghost exchange is a **proof-friendly sketch** — full overlap comm pending WP-PAR-70–72.
