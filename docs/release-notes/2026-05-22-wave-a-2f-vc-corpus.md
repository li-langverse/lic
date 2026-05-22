# Wave A 2f — VC discharge corpus + verify lean

## Summary

Wired `contracts_discharge_corpus.sh` and `contracts_verify_lean.sh` into `compiler-studio-plan-gates.sh`, Lean CI, and consolidated verify-lean to run the corpus first. **`sqrt_open_bound`** remains intentionally open; closure criteria documented in `docs/verification/sqrt-open-bound.md`.

## Verify

```bash
./scripts/build.sh
./li-tests/tooling/contracts_discharge_corpus.sh
./li-tests/tooling/contracts_verify_lean.sh
./scripts/compiler-studio-plan-gates.sh
./scripts/verify-math-physics-goldens.sh
./scripts/bench-verify-results.sh 1
```

## Policy

- `vc_sqrt_open_ensures_0` must stay open under default `lic build` (corpus asserts via `check-autovc-open-goals.sh`).
- `--allow-open-vc` required for `sqrt_open_bound.li` codegen path until P-float lemmas land.
