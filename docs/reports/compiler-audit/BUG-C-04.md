# BUG-C-04 — Horner FMA numerically-stable flag

**Gap script:** `li-tests/tooling/horner_fma_numerically_stable_gap.sh`  
**Status:** Resolved

## Summary

G-hw / G-meta / PH-7e: Horner FMA MIR ops now honor `--numerically-stable` via `EmitCtx::emit_fma_f64` (mirror matmul `fp_numerically_stable` gate).
