# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** **Resolved** — `Li.Discharge.broadcast_len1_add_float4_spec` + VC witness (#574)

## Summary (from gap script)

G-math / PH-2i: length-1 broadcast lowers in MIR/codegen with Lean semantics and VC witness via `broadcast_len1_add_float4_spec_proved`. Closed specimen: `linalg_broadcast_len1_add_float4_closed.li` (`prove_lean_ok`). `math_linalg/broadcast_len1_*.li` remain compile-only smoke.

## Owner action

MIR/codegen ↔ `broadcast_len1_add_float4_eval` refinement (same class as BUG-C-05 `mat2_at2_eval`).
