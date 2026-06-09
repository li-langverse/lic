# G-par / G-dec: MIR proc tags + Lean discharge corpus (#387)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-7d, G-par, G-dec  
**Issue:** #387

## Summary

Counts `OmpParallelFor.parallel_disjoint_proven` in `mir_parallel_disjoint=` telemetry (loop + `@parallel(disjoint=)` on `def`), wires G-par/G-dec MIR and Lean discharge scripts into `contracts_discharge_corpus.sh`, and links Phase 7d exit gates to **G-par** / **G-dec** IDs.

## Agent continuation

1. Run: `./scripts/build.sh && ./li-tests/tooling/contracts_discharge_corpus.sh`
2. Next: iteration-independence Lean specs (7d-c); Tier 2 MD `@cpu`/`@parallel`/`@vectorized` on `def` example.
3. Blocked on: full **P-par** iteration-independence proofs — not this PR.

## Changed

| Area | What | Evidence |
|------|------|----------|
| MIR | `count_mir_parallel_disjoint_proven` scans proc decorators + `OmpParallelFor` | `compiler/mir/mir.cpp` |
| CI | G-par/G-dec scripts in 2f corpus | `contracts_discharge_corpus.sh` |
| CI | Def inherit MIR tag on `@parallel(disjoint=)` | `check-mir-parallel-decorator.sh` |
| Doc-c | Phase 7d exit gates → G-par / G-dec | `2026-05-14-phase-07-native-hpc.md`, `provability-gaps.md` |

## Not changed

- Iteration-independence Lean specs beyond policy-witness slice
- `@parallel` codegen behavior (OpenMP runtime unchanged)

## Breaking / Security / Performance / Downstream

N/A
