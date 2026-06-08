# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** Closed (Lean spec + witness)

## Summary

G-math / PH-2i: length-1 broadcast lowers in MIR/codegen **and** discharges via `Li.Discharge.broadcast_len1_*_spec` + VC witness (`vc_witness.cpp` / `vc_emit_lean.cpp`). Closed corpus: `linalg_broadcast_len1_add_float4_closed.li`, `linalg_broadcast_len1_mul_int4_closed.li` (`prove_lean_ok`).

## Owner action

~~Add Discharge spec + witness for broadcast_len1 lowering~~ — done in PH-2i / lic#574.
