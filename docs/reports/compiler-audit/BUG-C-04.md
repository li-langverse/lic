# BUG-C-04 — Horner FMA numerically-stable flag

**Gap script:** `li-tests/tooling/horner_fma_numerically_stable_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-hw / G-meta / PH-7e: Horner FMA MIR ops ignore `--numerically-stable` (contrast matmul emit.cpp:232-247). HornerFmaUnroll / HornerStepPow4 / FmaFloatF64 always emit `llvm.fmuladd`.

## Owner action

Honor numerically-stable in Horner codegen or document as hardware_axiom tier-2 only.
