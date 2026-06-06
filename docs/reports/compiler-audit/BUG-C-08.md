# BUG-C-08 — parallel disjoint Lean stubs

**Gap script:** `li-tests/tooling/parallel_disjoint_lean_opaque_gap.sh`  
**Status:** Resolved

## Summary

G-par (#387): `disjoint_row` / `disjoint_elem` / `row_ok` contracts emit `Li.Discharge.*_spec` in AutoVC and discharge via `*_policy_witness` theorems.
