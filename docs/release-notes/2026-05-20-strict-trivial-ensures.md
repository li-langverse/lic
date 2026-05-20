# Release notes: strict trivial `ensures` (W0601 / E0303)

## Summary

Value-returning `def` procedures may no longer hide behind meaningless `ensures true`: the typechecker emits **W0601** by default and **E0303** when **`--strict-contracts`** or **`LI_STRICT_CONTRACTS=1`** is set; `extern proc` and **`-> unit`** stay exempt.

## Agent continuation

1. **Read** `docs/language/contracts-and-proofs.md`, `docs/language/errors.md`, `compiler/types/typecheck.cpp` (trivial-ensures check).
2. **Run** `./li-tests/run_all.sh typecheck` and `lic check <file> --strict-contracts` on a package you care about.
3. **Then** replace stub `ensures true` with postconditions that mention `result` (or use `-> unit`).
4. **Blocked on** Lean discharge wiring if you need machine proofs, not just surface checks.

## Changed

| Path | Change |
|------|--------|
| `compiler/types/typecheck.{hpp,cpp}` | `TypecheckOptions.strict_contracts`; detect literal `ensures true` |
| `compiler/diagnostics/*` | **E0303**, **W0601** codes + JSON agent ids |
| `compiler/lic/main.cpp` | `--strict-contracts` for `check`, `build`, `verify`; `LI_STRICT_CONTRACTS` env |
| `li-tests/run_all.sh` | `compile_fail_strict` outcome |
| `li-tests/typecheck/trivial_ensures_value_strict.li` | Regression |
| `docs/language/contracts-and-proofs.md`, `errors.md` | User-facing policy |

## Not changed

- `extern proc` may still use `ensures true` for opaque FFI.
- Lean VC pipeline and `lic verify` proof strength (surface warning/error only).
- Procedures that already state real properties on `result`.

## Breaking

**Opt-in only:** default remains **warning** (exit 0). CI must pass **`--strict-contracts`** or **`LI_STRICT_CONTRACTS=1`** to fail builds on trivial `ensures`.

## Security / Performance / Downstream

N/A.
