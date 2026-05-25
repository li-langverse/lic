# P-float: close sqrt_open_bound discharge corpus

## Summary

`sqrt_open_bound.li` AutoVC ensures now map to `Li.Discharge.sqrt_open_bound_spec` with `_proved` from trusted libm axiom `li_rt_sqrt_bound` (not full IEEE proof).

## Agent continuation

1. **Read:** `docs/semantics/Discharge.lean`, `li-tests/contracts_verify/sqrt_open_bound.li`, `compiler/verify/vc_emit_lean.cpp`.
2. **Run:** `./li-tests/tooling/discharge_sqrt_open_lean.sh`; `./li-tests/tooling/contracts_discharge_corpus.sh`; `./li-tests/run_all.sh contracts_verify`.
3. **Then:** P-refine real Props; P-ensures-witness for non-literal returns; migrate trusted axioms to `trusted.lean`.
4. **Blocked on:** Full IEEE float proof (**G-hw** axiomatic).

## Changed

| Path | Evidence |
|------|----------|
| `docs/semantics/Discharge.lean` | `Li.TrustedMath.li_rt_sqrt_bound`, `sqrt_open_bound_spec_proved` |
| `compiler/verify/vc_witness.cpp`, `vc_emit_lean.cpp` | `witness_sqrt_open_bound_spec`, semantic ensures emission |
| `li-tests/tooling/discharge_sqrt_open_lean.sh` | Zero open goals + grep spec |
| `li-tests/manifest.toml` | `prove_lean_ok` for sqrt specimen |
| `docs/verification/proof-corpus-roadmap.md`, `provability-gaps.md` | Honesty update |

## Not changed

- G-test-verify manifest machinery (already Done).
- Full Lean kernel as universal certificate (**G-lean** partial).
- P-refine alias/guard lemmas, P-par, P-dec, matmul float Props.

## Breaking

N/A — proof corpus closure only.

## Security

N/A — no trusted creep beyond documented libm axiom in `Discharge.lean`.

## Performance

N/A — discharge-only.

## Downstream

N/A — lic-only.
