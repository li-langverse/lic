# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-math / PH-2i: length-1 broadcast lowers in MIR/codegen but has no Lean semantics or VC witness. Contrast: `mat2_at2_float_spec` / `dot4_int_spec` in Discharge.lean; manifest `compile_ok` only.

## Owner action

Add Discharge spec + witness for broadcast_len1 lowering; agent: keep catalog `proof_status` ≤ open/target.
