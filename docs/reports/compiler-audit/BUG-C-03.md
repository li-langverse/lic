# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** Closed (Lean spec)

## Summary (from gap script)

G-math / PH-2i: length-1 broadcast lowers in MIR/codegen; **closed slice:** `Li.Discharge.broadcast_rhs_len1_add_float4_spec` + `linalg_broadcast_len1_add_float4_closed.li` (`prove_lean_ok`). Smoke `broadcast_len1_*.li` remain `compile_ok`.

## Owner action

~~Add Discharge spec + witness for broadcast_len1 lowering~~ Done in #574. Remaining: general NumPy rank broadcast; MIR↔eval refinement lemma (future **G-trust**).
