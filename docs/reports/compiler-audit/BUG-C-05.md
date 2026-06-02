# BUG-C-05 — mat2 `@` MIR vs Lean eval

**Gap script:** `li-tests/tooling/mat2_at2_mir_codegen_lean_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-lean / G-meta / G-math: 2×2 `@` Lean certificate uses `mat2_at2_eval`; MIR uses `ArrayMatMul2DF64`. No lemma links codegen to `Li.Discharge.mat2_at2_eval`.

## Owner action

Prove or trust-link MIR matmul2 path to `mat2_at2_eval`; prioritize in P-linalg backlog.
