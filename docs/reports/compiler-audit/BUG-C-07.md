# BUG-C-07 — method requires in Lean

**Gap script:** `li-tests/tooling/method_call_requires_lean_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-oop / G-vc: method `requires self.field >= arg` opaque in AutoVC; call-site stubs `True` via C++ const folding — not Lean FieldAccess semantics.

## Owner action

Translate method requires / FieldAccess in `expr_to_lean` (see also BUG-C-11 vec3_dot).
