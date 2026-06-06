# Close broadcast_len1 Lean semantics (PH-2i / BUG-C-03)

## Summary

Length-1 element-wise broadcast (`array[N,T]` × `array[1,T]`) now has closed Lean Props in `Li.Discharge`, VC witness wiring, and three `contracts_verify` specimens (add float4, mul int4, pow int4).

## Agent continuation

1. **Read:** `docs/semantics/Discharge.lean` (`broadcast_len1_*`), `compiler/verify/vc_witness.cpp` (`witness_broadcast_len1_discharge`).
2. **Run:** `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`; `lic build li-tests/contracts_verify/linalg_broadcast_len1_*_closed.li`.
3. **Next:** general NumPy rank broadcast; parametric N in Lean spec (not hard-coded 4).

## Changed

| Path | Evidence |
|------|----------|
| `docs/semantics/Discharge.lean` | `broadcast_len1_add/mul/pow_*_spec_proved` |
| `compiler/verify/vc_witness.cpp` | `witness_broadcast_len1_discharge` |
| `compiler/verify/vc_emit_lean.cpp` | eval-substitution AutoVC emission |
| `li-tests/contracts_verify/linalg_broadcast_len1_*_closed.li` | manifest `verify_ok` |
| `docs/verification/provability-gaps.md` | **G-math** closed slice row |

## Not changed

- Full NumPy-style rank broadcast rules (still compile-only negative tests).
- MIR↔eval preservation lemma for broadcast loops (semantic eval only).
