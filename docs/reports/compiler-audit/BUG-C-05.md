# BUG-C-05 — mat2 `@` MIR vs Lean eval

**Gap script:** `li-tests/tooling/mat2_at2_mir_codegen_lean_gap.sh`  
**Status:** Resolved (eval discharge; MIR↔eval lemma deferred)

## Summary

G-lean / G-meta / G-math: 2×2 `@` Lean certificate uses `mat2_at2_eval`; MIR uses `ArrayMatMul2DF64`. Closed eval discharge; no codegen preservation lemma (intentional deferral).

## Resolution

- Manifest tiers `linalg_mat2_at2_float_closed.li` as `verify_ok`
