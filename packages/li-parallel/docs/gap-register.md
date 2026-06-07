# li-parallel gap register

<!-- DOC-PAR-12 -->

Open work packages blocking killer gate completion. Updated 2026-06-07.

## Phase 1 — Shared memory

| WP | Gap | Status |
|----|-----|--------|
| WP-PAR-15 | `team()` / program-first `reduce` | **DONE** — `team_block_reduce_f64.li` + compile smoke |
| WP-PAR-17 | Variable cores / scoped team | **DONE** — `li_exec_team_push/pop` stack + scope smoke |
| WP-PAR-18 | Callable parallel defs | **DONE** — var array params + outlined capture via shared buffer |
| WP-PAR-19 | Unlimited/auto cores | **DONE** — `team(cores=0)` auto-inherit, cap 256 via `li_par_max_threads()` |

## Phase 2 — Distributed

| WP | Gap | Status |
|----|-----|--------|
| WP-PAR-20 | Programmed `hosts=[...]` cluster | **DONE** — lipar-run + exec plan hosts; 4-rank MD weak-scaling smoke |
| WP-PAR-22 | scatter/gather/scan/barrier | **DONE** — collectives + 4-rank smoke + MD weak-scaling specimen |

## Phase 4 — Benchmarks

| WP | Gap | Status |
|----|-----|--------|
| WP-PAR-40 | Strict perf vs OpenMP/MPI | **DONE** — reduce_sum strict speedup green (161× closed-form formula partition) |
| WP-PAR-48 | Whole-catalog dual-mode audit | **DONE** — killer gate step 3: 152 benchmarks, dual-mode complete |

## Phase 6–8 — FL, comm, hetero, xfer

| WP range | Gap | Status |
|----------|-----|--------|
| WP-PAR-60–65 | Federated learning hardening | **DONE** — partial ranks, stragglers, compressed halos, hetero, overlap, shrink smokes |
| WP-PAR-70–75 | Compiler comm plan | **DONE** — __li_comm_plan, overlap comm MIR, MD ghost overlap ≥50%, RDMA hooks, latency + compressed halo benches |
| WP-PAR-07–09 | Embedded execution plan | **DONE** — team/cluster/offload/overlap comm compile + runtime apply at main |
| WP-PAR-79–86 | Chip packages + boundaries | **DONE** — li-gpu (`import ligpu`), li-tpu, li-asic, hetero orchestration gate |
| WP-PAR-87–92 | Transfer plan | **DONE** — __li_xfer_plan, elide copy/fuse xfer/d2d path/rdma gpu, dashboard xfer_sec/elided_copies |

## Documentation (this sprint)

| WP | Deliverable | Status |
|----|-------------|--------|
| WP-PAR-50 | Handbook chapter | **DONE** |
| WP-PAR-51 | API reference | **DONE** |
| WP-PAR-52 | Migration guides | **DONE** |
| WP-PAR-53 | Examples corpus | **DONE** |
| WP-PAR-54 | mkdocs nav manifest | **DONE** |
| WP-PAR-55 | Gap register | **DONE** |

## Proof gaps

| Gap | Status |
|-----|--------|
| G-par | Partial |
| G-par-dist | Closed slice |
| G-hetero | Closed slice |
| P-par iteration independence (7d-c) | **Closed slice** — `par_iteration_independent_tile` + `iteration_independent_tile_spec` |
| P-par flat-array aliasing (7d-c) | **Closed slice** — `par_memory_disjoint_elems` + `memory_disjoint_elems_spec` + `array_elem_indices_disjoint` |
| P-par nested-grid aliasing (7d-c) | **Closed slice** — `par_memory_disjoint_grid_rows` + `memory_disjoint_grid_rows_spec` + `array_row_indices_disjoint` |

See [proofs table](proofs-table.md) and [provability gaps](../../../docs/verification/provability-gaps.md).
