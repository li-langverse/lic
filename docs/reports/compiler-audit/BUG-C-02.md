# BUG-C-02 — bounds guard codegen

**Gap script:** `li-tests/tooling/bounds_guard_codegen_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-bnd / G-vc: refinement-typed array index — codegen omits `li_bounds_fail`; callee AutoVC strips bounds.

## Owner action

Wire bounds failure paths in codegen + Lean discharge; agent: update provability-gaps.md when closed.
