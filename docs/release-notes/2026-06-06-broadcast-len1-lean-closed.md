# Close broadcast_len1_add_float4 Lean spec (PH-2i / #574)

## Summary

Length-1 rhs broadcast add on `array[4, float]` + `array[1, float]` now has a closed Lean Prop/eval pair in `Li.Discharge`, VC witness wiring, and `prove_lean_ok` specimen.

## Changed

| Path | Evidence |
|------|----------|
| `docs/semantics/Discharge.lean` | `broadcast_len1_add_float4_spec` + `broadcast_len1_add_float4_eval` + `rfl` proof |
| `compiler/verify/vc_witness.cpp`, `vc_emit_lean.cpp` | Witness + AutoVC discharge |
| `li-tests/contracts_verify/linalg_broadcast_len1_add_float4_closed.li` | P-linalg closed corpus |
| `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` | Gap script now asserts closed Lean path |
| `docs/verification/provability-gaps.md` | **G-math** / **G-lean** closed slice |

## Not changed

- MIR/codegen ↔ eval refinement (same open class as BUG-C-05 `mat2_at2_eval`)
- `math_linalg/broadcast_len1_*.li` remain `compile_ok` smoke (trivial main-only AutoVC)

## Tests

```bash
./scripts/build.sh
./li-tests/tooling/broadcast_len1_codegen_lean_gap.sh
./li-tests/tooling/discharge_linalg_int_lean.sh
lic build li-tests/contracts_verify/linalg_broadcast_len1_add_float4_closed.li
```
