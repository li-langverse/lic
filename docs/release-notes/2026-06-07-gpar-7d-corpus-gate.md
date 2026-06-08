# G-par / G-dec: Phase 7d closed slice — MIR proc tags + Lean policy witnesses

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-7d, G-par, G-dec  
**Issue:** [#387](https://github.com/li-langverse/lic/issues/387)

## Summary

Wires existing `@parallel` / `@vectorized` MIR proc telemetry and G-par Lean discharge
(`parallel_disjoint_lean_opaque_gap.sh`) into the 2f discharge corpus and master-plan gates.
Updates provability-gaps and master-plan tracker with closed-slice evidence.

## Changed

| Area | What | Evidence |
|------|------|----------|
| CI corpus | Run MIR + G-par scripts in `contracts_discharge_corpus.sh` | `check-mir-{parallel,vectorized}-decorator.sh`, `parallel_disjoint_lean_opaque_gap.sh` |
| Master plan | Phase 7d closed-slice note | `scripts/check-master-plan-gates.sh` |
| Docs | **G-par** / **G-dec** rows + proof-db discrepancy | `docs/verification/provability-gaps.md`, `proof-database/DISCREPANCIES.md` |

## Not changed (scope fence)

- Iteration-independence Lean specs (**P-par**) — still open
- Lean **P-dec** decorator elaboration proofs
- `@gpu` LKIR lowering / address-space proofs

## Agent continuation

1. Run `./scripts/build.sh && ./li-tests/tooling/contracts_discharge_corpus.sh`
2. Human merge; close #387 when CI green
