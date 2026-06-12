# Phase 2f / G-lean — close sqrt_open_bound

## Summary

Enable `witness_sqrt_open_bound_spec` for the `sqrt_open` proc; discharge `sqrt_open_bound.li` via `Li.Discharge.sqrt_open_bound_spec` and trusted `li_rt_sqrt_bound`. Retag manifest `prove_lean_ok`. Default `lic build` already runs Tier B Lean (`lake build AutoVC`) unless `--no-lean-verify`.

## Verify

```bash
./scripts/build.sh
./li-tests/tooling/discharge_sqrt_open_lean.sh
./li-tests/tooling/vec3_len_callproc_ensures_gap.sh
./li-tests/tooling/contracts_discharge_corpus.sh
```

## Changed

| Path | Evidence |
|------|----------|
| `compiler/verify/vc_witness.cpp` | remove `sqrt_open` discharge exclusion |
| `li-tests/manifest.toml` | `prove_lean_ok` for `sqrt_open_bound.li` |
| `li-tests/tooling/discharge_sqrt_open_lean.sh` | zero open AutoVC + `_proved` theorem |
| `docs/verification/provability-gaps.md` | G-lean / G-vc / G-test-verify rows |

## Not changed

- Full libm/IEEE proof (still **G-hw** axiomatic via `trusted.lean`).
- Universal Lean kernel certificate (**G-lean** remains Partial).
