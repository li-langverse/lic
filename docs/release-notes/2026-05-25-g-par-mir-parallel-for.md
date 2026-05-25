# G-par: MIR tag for parallel-for disjoint witnesses

## Summary

Policy-accepted `parallel for` disjoint witnesses set `OmpParallelFor.parallel_disjoint_proven` and **P-par** `disjoint_par_policy_witness`.

## Agent continuation

1. Read `docs/verification/provability-gaps.md` (**G-par**).
2. Run `./scripts/build.sh && ./scripts/check-mir-parallel-for-disjoint.sh`.
3. Next: Lean iteration-independence specs (7d-c).

## Not changed

**G-dec** decorator MIR; OpenMP codegen.

## Breaking / Security / Performance / Downstream

N/A
