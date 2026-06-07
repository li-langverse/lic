# li-parallel provability table

<!-- DOC-PAR-10 -->

Honest proof status for li-parallel surfaces. Canonical register: [provability-gaps.md](../../../docs/verification/provability-gaps.md).

| Gap | Surface | Status | Evidence |
|-----|---------|--------|----------|
| **G-par** | `parallel for` disjoint writes | **Partial** | 6× `compile_fail` + `good_disjoint_parallel.li` `verify_ok` + `team_block_reduce_f64.li` + `parallel_def_disjoint_inherit.li` smokes; Lean discharge open |
| **G-par-dist** | Block partition + `distributed for` | **Closed slice** | `li_dpar_block_partition_*` + `dpar_for_range.li` smoke |
| **G-hetero** | GPU/TPU/ASIC orchestration | **Closed slice** | `li_rt_hetero_*` + chip package probes + `hetero_mask_bounded` |
| WP-PAR-15 | Team-scoped `reduce` | **Closed slice** | `team_block_reduce_f64.li` + `team_reduce_tile_disjoint` lemma |
| WP-PAR-16 | Tree reduction policy | **Closed slice** | `reduce_tile_disjoint` in `parallel/proof.li` |
| WP-PAR-18 | Callable `@parallel` defs | **Closed slice** | `parallel_def_callable.li` + `def_disjoint_inherit_tile` lemma |
| WP-PAR-30 | Package proof helpers | **Closed slice** | `disjoint_tile`, `disjoint_block`, `partition_block_in_range`, `hetero_mask_bounded`; proof-db `parallel-li-par.toml` |

## Package lemmas

| Lemma | Module | Role |
|-------|--------|------|
| `disjoint_tile` | `parallel/proof.li` | Tile index bound |
| `disjoint_block` | `parallel/proof.li` | Block write isolation stub |
| `reduce_tile_disjoint` | `parallel/proof.li` | Reduction under disjoint tiles |
| `team_cores_bounded` | `parallel/proof.li` | Team scope within thread cap (WP-PAR-19) |
| `team_reduce_tile_disjoint` | `parallel/proof.li` | Team-scoped reduce inherits tile policy |
| `def_disjoint_inherit_tile` | `parallel/proof.li` | G-par decorator-inherited disjoint mirrors tile policy |
| `partition_row` | `parallel/proof.li` | Rank-local row mapping |
| `partition_block_in_range` | `parallel/proof.li` | G-par-dist block partition bound |
| `hetero_mask_bounded` | `parallel/proof.li` | G-hetero chip mask contract |

## Closing order

1. Structured `disjoint=` elaboration (**G-par**, WP-PAR-07–09)
2. Lean discharge for parallel VCs (**G-lean**)
