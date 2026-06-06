# li-parallel provability table

<!-- DOC-PAR-10 -->

Honest proof status for li-parallel surfaces. Canonical register: [provability-gaps.md](../../../docs/verification/provability-gaps.md).

| Gap | Surface | Status | Evidence |
|-----|---------|--------|----------|
| **G-par** | `parallel for` disjoint writes | **Partial** | 6× `compile_fail` + `good_disjoint_parallel.li` `verify_ok`; Lean discharge open |
| **G-par-dist** | Block partition + `distributed for` | **Closed slice** | `li_dpar_block_partition_*` + `dpar_for_range.li` smoke |
| **G-hetero** | GPU/TPU/ASIC orchestration | **Pending** | WP-PAR-07–09, WP-PAR-79–86 |
| WP-PAR-16 | Tree reduction policy | **Closed slice** | `reduce_tile_disjoint` in `parallel/proof.li` |
| WP-PAR-30 | Package proof helpers | **Partial** | `disjoint_tile`, `disjoint_block`; G-par-dist register row pending |

## Package lemmas

| Lemma | Module | Role |
|-------|--------|------|
| `disjoint_tile` | `parallel/proof.li` | Tile index bound |
| `disjoint_block` | `parallel/proof.li` | Block write isolation stub |
| `reduce_tile_disjoint` | `parallel/proof.li` | Reduction under disjoint tiles |
| `partition_row` | `parallel/proof.li` | Rank-local row mapping |

## Closing order

1. Structured `disjoint=` elaboration (**G-par**, WP-PAR-07–09)
2. G-par-dist + G-hetero rows in provability register (WP-PAR-30)
3. Lean discharge for parallel VCs (**G-lean**)
