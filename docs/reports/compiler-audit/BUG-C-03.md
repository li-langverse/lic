# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** Closed (2026-06-06)

## Summary (from gap script)

G-math / PH-2i: length-1 broadcast lowers in MIR/codegen with Lean semantics and VC witness. Closed slice: `linalg_broadcast_len1_add_float4_closed.li` → `Li.Discharge.broadcast_len1_add_float4_spec`.

## Resolution

- `Discharge.lean`: `broadcast_len1_add_float4_spec` / `_eval` / `_spec_proved`
- `vc_witness.cpp` + `vc_emit_lean.cpp`: `witness_broadcast_len1_add_float4_spec`
- Manifest: `contracts_verify/linalg_broadcast_len1_add_float4_closed.li` → `verify_ok`

Int/mul/pow broadcast smoke tests remain `compile_ok`; general NumPy rank rules still open.
