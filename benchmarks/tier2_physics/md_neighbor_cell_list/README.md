# md_neighbor_cell_list (algo 105)

Tier-2 harness for **cell-linked neighbor list** forces (`LI_MD_USE_CELL_LIST`).

- **Parity gate:** `max |F_cell − F_brute| @ N=256` via `li_md_force_parity_cell_vs_brute`.
- **Reference:** `md_lennard_jones` brute O(N²) MIC oracle.
- **Catalog:** `benchmarks/catalog.toml` → `md_neighbor_cell_list`.
