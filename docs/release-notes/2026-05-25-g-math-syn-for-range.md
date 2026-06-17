# Release notes: 2026-05-25 — g-math-syn-for-range

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-2h, **G-math-syn**

## Summary (one sentence)

Documents and tests **`for i in start..<end`** and **`for i in range(n)`** (compile-time bound) as **G-math-syn** closed slices; dynamic `range()` remains open.

## Agent continuation (required)

1. Read: `docs/verification/provability-gaps.md` and `li-tests/math_syntax/for_range_sum.li`.
2. Run: `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh math_syntax`.
3. Then: dynamic `range()` bounds if needed.
4. Blocked on: none for this slice.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Corpus | `math_syntax/for_range_sum.li`, `for_range_literal_ok.li`, `for_range_const_ok.li` | `verify_open_ok` / `compile_ok` |
| Corpus | `math_syntax/for_range_dynamic_fail.li` | `compile_fail` |
| Register | `provability-gaps.md` **G-math-syn** | Partial |

## Not changed (scope fence)

- Dynamic `range()` bounds — not in this PR
- **G-par**, **G-dec**, **G-vc** — other open PRs (#193, #196)

## Breaking changes

None.

## Security

N/A.

## Performance

N/A.

## Downstream

N/A.
