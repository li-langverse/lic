# Wave A 2f — G-lean strict build smoke

## Summary

`lic build` emits `AutoVC.lean` with `LiArray` surface; **tier B** Lean gates are green: lake typecheck on generated AutoVC and `--strict-lean` closed-contract build.

## Verify

```bash
./scripts/build.sh
./li-tests/tooling/autovc_lake_typecheck.sh
./li-tests/tooling/glean_strict_build_smoke.sh
./scripts/compiler-studio-plan-gates.sh
```

Specimen: `li-tests/contracts_verify/linalg_dot4_int_closed.li` (closed int dot, zero open Prop goals under `--strict-lean`).

## CI

Lean workflow runs `autovc_lake_typecheck.sh` and `glean_strict_build_smoke.sh` after `lic` build (matches `compiler-studio-plan-gates.sh`).
