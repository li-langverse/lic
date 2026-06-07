# G-par: Lean discharge for `parallel for` `_par*` VCs

## Summary

Policy-accepted `disjoint_elem` / `disjoint_row` / `disjoint_slice` / `row_ok` on `parallel for` now emit
`Li.Discharge.*_spec` Props in `AutoVC.lean` and close via `*_policy_witness` theorems. MIR sets
`OmpParallelFor.parallel_disjoint_proven` when the AST disjoint witness is present.

## Agent continuation

1. Read `docs/verification/provability-gaps.md` (**G-par**).
2. Run `./scripts/build.sh && ./li-tests/tooling/discharge_par_parallel_lean.sh && ./scripts/check-mir-parallel-for-disjoint.sh`.
3. Next: iteration-independence Lean specs (7d-c), not pattern-only heuristics.

## Not changed

**G-dec** decorator MIR lowering; OpenMP runtime (WP1).
