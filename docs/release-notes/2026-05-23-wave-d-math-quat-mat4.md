# Release notes: AL-11 math quat + Mat4 + scene transforms (2026-05-23)

## Summary

**wave-d-04-math-quat-mat4 (AL-11):** `quat_dot`, `quat_slerp`, `mat4_mul` on `import math`; `Transform3` on `import scene` uses `math.Vec3` / `math.Quat` instead of raw `qx..qw` fields.

## Changes

- `packages/li-math/src/lib.li` — AL-11 quaternion + 4×4 multiply (`li_std_math_version` → 2)
- `packages/li-scene/src/lib.li` — `Transform3` wire-up + `transform_rotation_dot` (`li_std_scene_version` → 2)
- `li-tests/composable/import_math_quat_mat4.li`, `import_scene_transform3_math.li` — `compile_open_ok`

## Plan

Marks `wave-d-04-math-quat-mat4` completed on compiler-studio plan loop.
