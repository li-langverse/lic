# lic#4 — close sqrt_open_bound; default Lean gate on lic build

## Summary

Discharge `sqrt_open_bound.li` via `Li.Discharge.sqrt_open_bound_spec` + `Li.TrustedMath.li_rt_sqrt_bound`; retag manifest `prove_lean_ok`. Default `lic build` already invokes `lake build AutoVC` (`--no-lean-verify` opt-out per strict-by-default).

## Evidence

```bash
./scripts/build.sh
./li-tests/tooling/discharge_sqrt_open_lean.sh
./li-tests/tooling/contracts_discharge_corpus.sh
./li-tests/tooling/vec3_len_callproc_ensures_gap.sh
```

## Changed

| Path | Evidence |
|------|----------|
| `compiler/verify/vc_witness.cpp` | enable `witness_sqrt_open_bound_spec` for `sqrt_open` |
| `li-tests/manifest.toml` | `prove_lean_ok` for `sqrt_open_bound.li` |
| `li-tests/tooling/discharge_sqrt_open_lean.sh` | zero open AutoVC + `_proved` theorem |
| `docs/verification/provability-gaps.md` | G-lean / G-vc closed slice; Phase 2f tracker |

## Not changed

- Universal Lean kernel certificate (**G-lean** still Partial)
- Full IEEE/libm proof (**G-hw** axiomatic)
