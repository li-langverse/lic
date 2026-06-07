# PH-7d / G-par: MIR disjoint telemetry + corpus wiring (#387)

**Date:** 2026-06-07  
**Gaps:** **G-par** (Partial), **G-dec** (Partial)  
**Phase:** 7d, 2f

## Summary

`lic verify` now counts policy-accepted disjoint witnesses on both `@parallel(disjoint=…)` proc
decorators and `OmpParallelFor` loop bodies (`mir_parallel_disjoint=`). The 2f discharge corpus
runs `parallel_disjoint_lean_opaque_gap.sh`, `check-mir-parallel-for-disjoint.sh`, and (when
`lake` is installed) `discharge_par_parallel_lean.sh`.

## Changed

- `compiler/mir/mir.cpp` — `count_mir_parallel_disjoint_proven` scans `OmpParallelFor`
- `li-tests/tooling/contracts_discharge_corpus.sh` — G-par / G-dec MIR gates
- `li-tests/tooling/discharge_par_parallel_lean.sh` — absolute `LIC` path in temp build dir
- `docs/verification/provability-gaps.md` — **G-par** / **G-dec** evidence rows

## Not changed

- Iteration-independence Lean specs (**P-par** full discharge) — still open
- Tier 2 MD `@cpu` `@parallel` `@vectorized` on `def` example gate

## Agent continuation

1. Run `./scripts/build.sh && ./scripts/check-mir-parallel-for-disjoint.sh && ./li-tests/tooling/parallel_disjoint_lean_opaque_gap.sh`.
2. Next: iteration-independence Lean (7d-c), not pattern-only policy witnesses.
