# Release notes: wave-d-08 scene hierarchy (2026-05-23)

## Summary

**wave-d-08-scene-hierarchy:** Parent/child `SceneNode` hooks, TRS hierarchy via `transform_compose` / `scene_world_transform` using `math.Quat` (`quat_mul`, `quat_rotate_vec3`), and composable smoke (`scene_hierarchy_smoke_entry` → `1005`).

## Changes

- `packages/li-scene/src/lib.li` — hierarchy compose + `scene_node_new` (`li_std_scene_version` → 3)
- `li-tests/composable/import_scene_hierarchy.li` — `compile_open_ok`

## Plan

Marks `wave-d-08-scene-hierarchy` completed on compiler-studio plan loop.
