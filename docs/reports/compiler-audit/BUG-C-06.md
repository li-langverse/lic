# BUG-C-06 — matmul loop witness

**Gap script:** `li-tests/tooling/matmul_loop_codegen_witness_gap.sh`  
**Status:** Resolved (partial)

## Summary

P-linalg / G-lean: tier-1 IKJ matmul loop path witness via `witness_matmul2_at2_spec` + `matmul2_at2_loop_eval_spec` (reuses closed 2×2 eval).

## Note

Full N×N loop↔ensures witness remains backlog; tier-1 FMA gate verified on `matmul_25x25_at_codegen.li`.
