# BUG-C-06 — matmul loop witness

**Gap script:** `li-tests/tooling/matmul_loop_codegen_witness_gap.sh`  
**Status:** Open

## Summary (from gap script)

P-linalg / G-lean: tier-1 IKJ matmul loop path (`ArrayMatMul2DF64`) has no loop→ensures witness. Contrast: `witness_dot4_int_loop` + `dot4_int_loop_eval_spec`.

## Owner action

Mirror dot4 loop witness pattern for general matmul loops.
