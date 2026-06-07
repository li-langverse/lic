# PH-7d / G-par: MIR proc tags + Lean disjoint corpus (#387)

**Date:** 2026-06-07  
**Gaps:** **G-par** (Partial), **G-dec** (Partial), **P-par** (Partial)  
**Phase:** 7d, 2f  
**Issue:** [#387](https://github.com/li-langverse/lic/issues/387)

## Summary

- `count_mir_parallel_disjoint_proven` now counts proved `@parallel(disjoint=…)` on `def` **and** `OmpParallelFor` sites with structured disjoint witnesses.
- `contracts_discharge_corpus.sh` runs `check-mir-{parallel,vectorized}-decorator.sh`, `check-mir-parallel-for-disjoint.sh`, and `parallel_disjoint_lean_opaque_gap.sh`.
- Phase 7 exit gates link **G-par** / **G-dec** IDs (Doc-c).

## Agent continuation

1. Read `docs/verification/provability-gaps.md` (**G-par**, **G-dec**).
2. Run `./scripts/build.sh && ./li-tests/tooling/contracts_discharge_corpus.sh`.
3. Blocked: **P-par** iteration-independence Lean proofs (beyond policy witnesses); Tier 2 MD `@cpu` `@parallel` `@vectorized` on `def` example.

## Changed

- `compiler/mir/mir.cpp`, `compiler/mir/include/li/mir.hpp`
- `li-tests/tooling/contracts_discharge_corpus.sh`
- `docs/verification/provability-gaps.md`
- `docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md`

## Not changed

- Lean **P-dec** elaboration proofs — open.
- Full **7d** phase complete checkbox — still partial per issue #387.

## Breaking / Security / Performance / Downstream

N/A
