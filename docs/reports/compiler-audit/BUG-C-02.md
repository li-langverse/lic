# BUG-C-02 — bounds guard codegen

**Gap script:** `li-tests/tooling/bounds_guard_codegen_gap.sh`  
**Status:** Resolved

## Summary

G-bnd / G-vc: refinement-typed array index — codegen omits `li_bounds_fail`; callee AutoVC strips bounds; call-site refine VCs auto-prove via folded Lean + `Li.Discharge.refinement_nonneg_lit_proved` / `by decide`.

## Resolution

- Removed witnessed call-site refine `Prop := True` stub override in `vc_emit_lean.cpp`
- Link `runtime/li_par_pool.c` with user builds (`compile.cpp`) so bounds gap link tests pass
