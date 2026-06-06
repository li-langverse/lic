# BUG-C-03 — broadcast len-1 Lean semantics

**Gap script:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`  
**Status:** Closed (2026-06-06)

## Summary (from gap script)

G-math / PH-2i: length-1 broadcast lowers in MIR/codegen with Lean `Li.Discharge.broadcast_len1_*_spec` Props, `witness_broadcast_len1_discharge` in `vc_witness.cpp`, and `contracts_verify/linalg_broadcast_len1_*_closed.li` manifest `verify_ok` rows.

## Owner action

~~Add Discharge spec + witness for broadcast_len1 lowering~~ Done — see `docs/release-notes/2026-06-06-broadcast-len1-lean-closed.md`.
