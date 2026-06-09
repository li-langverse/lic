# PH-7d / G-par: MIR proc tags + Lean disjoint corpus gate

**Date:** 2026-06-07  
**Gaps:** **G-par** (Partial), **G-dec** (Partial)  
**Phase:** 7d, 2f  
**Issue:** [#387](https://github.com/li-langverse/lic/issues/387)

## Summary

Wires the existing `@parallel(disjoint=…)` / `@vectorized(lanes=4)` MIR proc tags and Lean `Li.Discharge.*_policy_witness` discharge slice into the Phase 2f contracts corpus. Fixes `check-mir-parallel-decorator.sh` SIGPIPE under `set -o pipefail`.

## Agent continuation

1. Read `docs/verification/provability-gaps.md` (**G-par**, **G-dec**).
2. Run `./scripts/build.sh && ./li-tests/tooling/contracts_discharge_corpus.sh`.
3. Full iteration-independence Props (**P-par**) remain open — not this PR.

## Changed

- `scripts/check-mir-parallel-decorator.sh` — avoid nm|grep SIGPIPE
- `li-tests/tooling/contracts_discharge_corpus.sh` — run MIR decorator + G-par gap scripts
- `compiler/lic/main.cpp` — styled `mir_parallel_disjoint` telemetry
- `docs/verification/provability-gaps.md`, `docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md`

## Not changed

- Full **P-par** iteration-independence Lean Props (beyond policy witnesses)
- Tier 2 MD `@cpu` `@parallel` `@vectorized` on `def` example (phase 7d exit gate)
