# `for` / `range` surface — parse + typecheck Done gate (PH-2h / G-math-syn)

> **Issue:** [#527](https://github.com/li-langverse/lic/issues/527) · **Repo:** li-langverse/lic  
> **Vision:** **Easy** (Python-math ergonomics), **Provable** (compile-time bound witness path)  
> **Learned from:** [2026-05-14-li-master-plan.md](./2026-05-14-li-master-plan.md) (Phase 2h), [provability-gaps.md](../../verification/provability-gaps.md) (**G-math-syn**), `li-tests/math_syntax/` (operators `%`, `//`, `**`)

## Goal

Define the **Done gate** for **`for i in range(n)`** (and the `0..<N` half-open form already used in linalg samples) so Phase **2h** no longer defers `for`/`range` indefinitely under **G-math-syn Partial**. Deliver parse + typecheck + minimal compile-time bound witness path without requiring full iterator protocol or dynamic ranges.

## Non-goals

- General Python `for x in iterable` over arbitrary collections.
- Dynamic `range(start, stop, step)` with non-constant bounds in v1 (document defer).
- MIR lowering proofs for loop VCs (belongs to **P-loop** / **G-vc**, not syntax gate).
- `@parallel` / `@vectorized` interaction proofs (**G-par**, **7d**).

## Dependencies

- **PH-2h** — `%`, `//`, `**` already shipped (`math_syntax` suite).
- **PH-2i** — linalg samples use `for i in 0..<N`; align surface docs.
- Human: **`plan-approved`** before parser/typechecker changes.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Spec minimum** — document `for i in range(n)` and `0..<N` in handbook + phase-02 plan cross-link | `docs/language/` or math-syntax stub cites bound rules |
| B | **Parser** — accept `for IDENT in range(EXPR)` and existing half-open range | Parse errors stable; golden snapshot optional |
| C | **Typecheck** — `n` must be `int`; loop body `i: int`; reject non-integer range | `compile_fail` for float range / wrong type |
| D | **Compile-time bound witness path** — constant or refinement-local `n` records static trip for VC emit (pilot: match dot4 pattern prerequisites) | One `compile_ok` with `requires n == 4` style bound |
| E | **Tests** — `li-tests/math_syntax/for_range_compile_ok.li`, `for_range_compile_fail_nonint.li` | `./li-tests/run_all.sh math_syntax` green |
| F | **Gap register** — update **G-math-syn** row: operators + `for`/`range` closed slice | `provability-gaps.md` same PR as E |

## Tests / benches

- `li-tests/math_syntax/for_range_*.li` — at least one `compile_ok`, one `compile_fail`.
- Existing `li-tests/math_linalg/` — no regression on `0..<N` loops.
- No new tier-1 bench until linalg uses `range()` spelling in sources (optional follow-up).

## Provability

- **G-math-syn** — Partial → stronger Partial (syntax slice closed; iterator generality still open).
- **G-vc** — unchanged; loop VC witnesses remain **P-loop** backlog (#472).
- Do not mark **G-lean** **Done** from syntax-only work.

## Rollout

1. Merge plan PR → **`plan-approved`** on #527.
2. Implementation PR: sub B–E (parser + typecheck + tests).
3. Docs PR: sub A + F.
4. Master plan tracker: mark 2h `for`/`range` slice done; note deferred dynamic range.
5. Remove `plan-needed` on #527.

## Human-only

- Maintainer **`plan-approved`** before code agents.
- Confirm v1 surface: `range(n)` only vs also `range(0, n)` in same PR.
