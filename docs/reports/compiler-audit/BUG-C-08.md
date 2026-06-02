# BUG-C-08 — parallel disjoint Lean stubs

**Gap script:** `li-tests/tooling/parallel_disjoint_lean_opaque_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-par (#387): parallel-for `disjoint_row` / `disjoint_elem` / `row_ok` contracts emit opaque `True` stubs in AutoVC — `expr_to_lean` Call handler only translates `abs()`, not disjoint builtins.

## Owner action

Structured parallel proofs in Lean; agent: no `proved` on parallel specimens until gap passes.
