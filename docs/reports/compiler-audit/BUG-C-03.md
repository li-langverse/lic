# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** Closed slice (2026-06-06)

## Summary (from gap script)

G-math / PH-2i: length-1 broadcast lowers in MIR/codegen with closed Lean semantics (`broadcast_len1_add_float4_spec` in `Discharge.lean`, VC witness in `vc_witness.cpp`). Closed specimen `linalg_broadcast_len1_add_float4_closed.li` is `prove_lean_ok`; MIR smoke `broadcast_len1_*.li` remain `compile_ok`.

## Owner action

Mul/pow broadcast variants and full NumPy rank rules remain open; extend closed slice when contracts land.
