# Release notes: strict trivial `ensures` (W0601 / E0303)

## Summary

Value-returning `def` procedures may no longer hide behind **vacuous** postconditions: the typechecker emits **W0601** by default and **E0303** under **`--strict-contracts`** / **`LI_STRICT_CONTRACTS=1`**. Detected forms include **`ensures true`**, tautologies such as **`result == result`** / **`a == a`** / **`result <= result`**, **`true or …`**, **`not false`**, and **`true and …`** when both conjuncts are vacuous. **`extern proc`** and **`-> unit`** stay exempt.

## Agent continuation

1. **Read** `docs/language/contracts-and-proofs.md`, `docs/language/errors.md`, `compiler/types/typecheck.cpp` (trivial-ensures check).
2. **Run** `./li-tests/run_all.sh typecheck`, `./li-tests/run_all.sh contracts_verify`, and **`./scripts/audit-strict-good-contracts.sh`**.
3. **Then** replace stub `ensures true` with postconditions that mention `result` (or use `-> unit`).
4. **Blocked on** Lean discharge wiring if you need machine proofs, not just surface checks.

## Changed

| Path | Change |
|------|--------|
| `compiler/types/typecheck.cpp` | Vacuous `ensures` beyond `true`: tautologies (`result == result`, `x <= x`), `true or …`, `not false`, `true and …` when both sides vacuous; structural equality on `Expr` |
| `li-tests/typecheck/vacuous_*.li` | Strict regression cases |
| `li-tests/typecheck/provable_add_ok.li` | Good program under strict |
| `li-tests/manifest.toml` | `compile_ok_strict` outcome + tests |
| `li-tests/run_all.sh` | `compile_ok_strict` harness |
| `scripts/audit-strict-good-contracts.sh` | Spot-check proof-style programs with `--strict-contracts` |
| `docs/language/contracts-and-proofs.md`, `errors.md` | Documented patterns |

## Not changed

- No automatic migration of existing packages (warnings remain default).
- Full predicate calculus / SMT-style vacuity (future work).

## Breaking

Still **opt-in** via `--strict-contracts` / `LI_STRICT_CONTRACTS=1`.

## Security / Performance / Downstream

N/A.
