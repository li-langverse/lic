# BUG-C-10 — sum vs dot product equivalence

**Gap script:** `li-tests/tooling/sum_dot_product_equiv_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-math / G-vc / PH-2i: `sum(a*b)` and `dot(a,b)` lower to different MIR/codegen; no Lean equiv; `dot_via_sum_product.li` computes both but manifest `verify_ok` with trivial main AutoVC only.

## Owner action

Add Lean lemma linking sum-dot lowering or split catalog claims.
