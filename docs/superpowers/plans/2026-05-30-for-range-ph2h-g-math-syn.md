# `for` / `range` surface — parse + typecheck Done gate (PH-2h / G-math-syn)

> **Issue:** [#527](https://github.com/li-langverse/lic/issues/527) · **Repo:** li-langverse/lic  
> **Vision:** **Easy** (Python-math ergonomics), **Provable** (compile-time bound witness path)  
> **Learned from:** [2026-05-14-li-master-plan.md](./2026-05-14-li-master-plan.md) (Phase 2h tracker), [provability-gaps.md](../../verification/provability-gaps.md) (**G-math-syn**), [2026-05-25-g-math-syn-for-range.md](../../release-notes/2026-05-25-g-math-syn-for-range.md), `li-tests/math_syntax/for_range_sum.li`

## north_star_fit

Scientific / HPC numerics ergonomics (**Easy**) with static trip-count witnesses (**Provable**) before loop VC proofs (**G-vc**, **P-loop**). **PH-2h**, **G-math-syn**.

## Baseline (2026-06-04, `main`)

| Slice | Status | Evidence |
|-------|--------|----------|
| `%`, `//`, `**` on `int` | **Done** | `li-tests/math_syntax/int_*.li` |
| `for i in start..<end` | **Done** | `for_range_sum.li`; master plan Phase 2h checkbox |
| `for i in range(n)` (Python spelling) | **Open** | **G-math-syn** row; this plan |
| Dynamic `range(start, stop, step)` | **Deferred** | Non-constant bounds → follow-up issue |

**REQ-2h-for-range:** Parser + typechecker accept `for IDENT in range(EXPR)` with integer bound; emit compile-time trip witness for constant or refinement-local `n`; `math_syntax` compile_ok + compile_fail fixtures.

## Goal

Close the remaining **G-math-syn** syntax slice for **Python `range(n)`** so Phase **2h** no longer lists `range()` as deferred. Deliver parse + typecheck + minimal compile-time bound witness path without iterator protocol or dynamic ranges.

## Non-goals

- General Python `for x in iterable` over arbitrary collections.
- Dynamic `range(start, stop, step)` with non-constant bounds in v1 (document defer).
- MIR lowering proofs for loop VCs (belongs to **P-loop** / **G-vc**, not syntax gate).
- `@parallel` / `@vectorized` interaction proofs (**G-par**, **7d**).
- Re-litigate `0..<end` (already shipped; regression guard only).

## Dependencies

- **PH-2h** — operators + half-open loop already on `main`.
- **PH-2i** — linalg samples use `0..<N`; optional doc cross-link only.
- Human: **`plan-approved`** before parser/typechecker changes.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Spec minimum** — document `for i in range(n)` as sugar over half-open `[0, n)` with bound rules | `docs/language/` or math-syntax stub cites witness rules |
| B | **Parser** — accept `for IDENT in range(EXPR)`; preserve existing `start..<end` | Parse errors stable; no regression on `for_range_sum.li` |
| C | **Typecheck** — `n` must be `int`; loop body `i: int`; reject non-integer range | `compile_fail` for float / wrong type |
| D | **Compile-time bound witness path** — constant or refinement-local `n` records static trip for VC emit (pilot: dot4 / `for_range_sum` pattern) | One `compile_ok` with `requires n == 4` style bound |
| E | **Tests** — `li-tests/math_syntax/for_range_compile_ok.li`, `for_range_compile_fail_nonint.li` | `./li-tests/run_all.sh math_syntax` green |
| F | **Gap register** — update **G-math-syn**: `range(n)` closed; dynamic `range()` still open | `provability-gaps.md` + master plan line 446 note in same PR as E |

## Tests / benches

- `li-tests/math_syntax/for_range_*.li` — at least one `compile_ok`, one `compile_fail` (issue acceptance).
- `for_range_sum.li` — must stay green (half-open regression).
- `li-tests/math_linalg/` — no regression on `0..<N` loops.
- No new tier-1 bench until linalg adopts `range()` spelling (optional follow-up).

## Provability

| Gap | Before | After implementation |
|-----|--------|----------------------|
| **G-math-syn** | Partial — `range()` open | Partial — `range(n)` closed slice; dynamic bounds / iterables open |
| **G-vc** | Partial | Unchanged; loop VC witnesses remain **P-loop** (#472) |
| **G-lean** | Partial | Unchanged; syntax-only work |

Do not mark **G-lean** **Done** from syntax-only work.

## Rollout

1. Merge this plan PR → human adds **`plan-approved`** on #527; remove **`plan-needed`**.
2. Implementation PR: sub B–E (parser + typecheck + tests).
3. Docs PR: sub A + F (can combine with step 2 if small).
4. Master plan tracker: update line 446 — `range(n)` slice done; dynamic `range()` deferred.
5. Hand to **code_implementer** only after `plan-approved` + merged plan on `main`.

## Human-only

- Maintainer **`plan-approved`** before code agents.
- Confirm v1 surface: `range(n)` only vs also `range(0, n)` in same PR.
