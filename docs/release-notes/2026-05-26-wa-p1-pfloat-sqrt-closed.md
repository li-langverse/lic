# WA-P1 — P-float `sqrt_open_bound` closed

## Summary

`vc_sqrt_open_ensures_0` discharges via `Li.Discharge.sqrt_open_bound_spec` and trusted axiom
`Li.Trusted.li_rt_sqrt_square_bound` (**G-hw** libm slice). Default `lic build` on
`sqrt_open_bound.li` passes; `check-autovc-open-goals.sh` reports zero open Prop goals.

## Verify

```bash
./scripts/build.sh
./build/compiler/lic/lic build li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null
./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean
./li-tests/tooling/contracts_discharge_corpus.sh
```

## Policy

- `--allow-open-vc` defaults unchanged.
- Trusted surface documented in `docs/semantics/trusted.lean` and `README.md`.
