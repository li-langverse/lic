# Release notes: 2026-06-06 — g-math-syn-range-n

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-2h, **G-math-syn**  
**Issue:** #527

## Summary (one sentence)

Adds Python **`for i in range(n)`** parse+typecheck sugar (compile-time integer bound witness) alongside existing `start..<end` loops.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Parser | `range(n)` → `0..<n` desugar | `compiler/parser/parser.cpp` |
| Corpus | `math_syntax/for_range_ok.li` | `compile_ok` |
| Corpus | `math_syntax/for_range_dyn_fail.li` | `compile_fail` |
| Register | `provability-gaps.md` **G-math-syn** | Partial (dynamic bounds open) |

## Not changed (scope fence)

- Dynamic `range(expr)` bounds — rejected at parse
- **G-par**, **G-vc** — separate tracks

## Breaking changes

None.
