# BUG-C-01 — dot4 loop AutoVC emits `Prop := True` instead of Discharge spec

**Class:** Compiler (C)  
**Status:** Open — catalog honestly downgraded (Phase 5 WP-DS-01)  
**Affected specimens:** `linalg_dot4_int_loop_open.li`, `linalg_dot4_float_loop_open.li` (if present)

## Summary

When `lic build` / `lic verify` processes a 4-iteration dot-product loop with an `ensures` postcondition matching the closed form, AutoVC generation emits a static witness with `Prop := True` for the loop body obligation instead of wiring the proof obligation to `Li.Discharge.dot4_int_loop_eval_spec` (or the float variant).

The Lean discharge layer already defines `dot4_int_loop_eval_spec` as proved in `docs/semantics/Discharge.lean`, but the compiler VC emitter does not connect loop witnesses to that theorem.

## Reproduction

```bash
export LIC="$PWD/build/compiler/lic/lic"
"$LIC" build li-tests/contracts_verify/linalg_dot4_int_loop_open.li -o /dev/null
grep -A5 'dot4_int_loop' build/generated/AutoVC.lean
# Observe: loop ensures goal discharged via `Prop := True` stub, not `Li.Discharge.dot4_int_loop_eval_spec`
"$LIC" verify li-tests/contracts_verify/linalg_dot4_int_loop_open.li
# open_goals > 0 or ensures not linked to Discharge spec
```

## Classification

| Check | Result |
|-------|--------|
| Specimen syntactically valid | Yes |
| Lean bridge theorem exists | Yes (`Li.Discharge.dot4_int_loop_eval_spec`) |
| `lic verify` discharge | **Fails** — compiler mis-wiring |

**Verdict:** Compiler bug (C). Do **not** upgrade catalog `proof_status` to `proved` until verify passes with Discharge spec linkage.

## Recommended fix (human / compiler team)

1. In AutoVC loop witness emission, map 4-iteration int dot loops to `Li.Discharge.dot4_int_loop_eval_spec`.
2. Re-run `lic verify` on `linalg_dot4_int_loop_open.li` and confirm zero open goals.
3. Upgrade catalog row `P-linalg-dot4-int-loop-open` from `open` → `proved` with verify log evidence.

## Phase 5 disposition

Catalog row `P-linalg-dot4-int-loop-open` downgraded to `proof_status = open` with `gap_kind = proof_gap` and audit cross-ref to this report. See `data/proof-explorer-loop/bug-disposition/BUG-C-01.json`.

## References

- `docs/semantics/Discharge.lean` — `dot4_int_loop_eval_spec`
- `li-tests/contracts_verify/linalg_dot4_int_loop_open.li`
- `proof-db/lemmas/P-linalg-dot4-int-loop-open.toml`
- Plan: `docs/superpowers/plans/proof-explorer-phase5-discharge-sprint.md` WP-DS-01
