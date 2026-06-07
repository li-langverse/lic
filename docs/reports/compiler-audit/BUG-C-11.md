# BUG-C-11 — vec3_dot opaque ensures

**Gap script:** `li-tests/tooling/vec3_dot_opaque_ensures_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-vc / P-linalg / G-oop: float `vec3_dot` FieldAccess ensures opaque in AutoVC; Vec3 → Int erasure; local-alias pattern witnesses structurally but no `Li.Discharge` vec3 spec (contrast `linalg_dot4_float_closed`).

## Owner action

FieldAccess translation + `vec3_dot` Discharge spec; agent: downgrade any `proved` catalog rows for vec3 specimens.
