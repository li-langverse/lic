# Close broadcast_len1 Lean discharge (PH-2i / G-math)

## Summary

Length-1 element-wise broadcast (`array[1] × array[N]`) now has closed Lean Props in `Discharge.lean`, VC witness wiring, and `prove_lean_ok` contract specimens for float add and int mul.

## Agent continuation

1. **Read:** `docs/semantics/Discharge.lean` (`broadcast_len1_*_spec`), `compiler/verify/vc_witness.cpp`, `li-tests/contracts_verify/linalg_broadcast_len1_*_closed.li`.
2. **Run:** `./li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`, `./li-tests/tooling/discharge_linalg_int_lean.sh`.
3. **Next:** general NumPy rank broadcast; pow/sub/div closed Props; MIR↔eval refinement (**G-trust**).
4. **Blocked on:** full nd broadcast rules; SIMD gather proofs for vectorized broadcast loops.

## Changed

| Area | Path |
|------|------|
| Discharge | `docs/semantics/Discharge.lean` — `broadcast_len1_add_float4_*`, `broadcast_len1_mul_int4_*` |
| VC witness | `compiler/verify/vc_witness.cpp`, `vc_emit_lean.cpp` |
| Corpus | `li-tests/contracts_verify/linalg_broadcast_len1_*_closed.li`, `manifest.toml` |
| Gap script | `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` |
| Gaps | `docs/verification/provability-gaps.md` |

## Not changed

- `math_linalg/broadcast_len1_*.li` smoke tests remain `compile_ok` (runtime checks, no proc ensures).
- Full NumPy-style rank broadcast.

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A |
| **Security** | N/A |
| **Performance** | N/A |
| **Downstream** | N/A |
