# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** Closed (add slice)

## Summary (from gap script)

G-math / PH-2i: length-1 broadcast add has Lean semantics (`broadcast_len1_add_float4_spec`) + VC witness; `broadcast_len1_add_float4_closed.li` is `verify_ok`. Mul/pow/`**` broadcast and full NumPy rank rules remain open.

## Owner action

Extend closed slice to mul/pow/`**` broadcast ops when needed; keep catalog `proof_status` ≤ open/target for open variants.
