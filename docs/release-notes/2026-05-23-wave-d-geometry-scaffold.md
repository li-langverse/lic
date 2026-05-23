# Release notes: AL-13 `li-geometry` scaffold (2026-05-23)

## Summary

**wave-d-15-geometry-scaffold (AL-13):** first **`import geometry`** package with explicit mesh predicates (`orient2d`, `orient3d`, `incircle2d`) and composable smoke test (`workload_class=stub`).

## Changes

- `packages/li-geometry/` — scaffold via `li-new-package`; `import_name = "geometry"`; `workload_class=stub`
- `packages/li-geometry/src/lib.li` — `MeshTriangle2`, `MeshTet3`, predicate stubs + closed-form smoke witnesses
- `li-tests/composable/import_geometry_mesh_predicates.li` — `compile_open_ok`
- `packages/li.toml` — workspace member `li-geometry`

## Plan

Marks `wave-d-15-geometry-scaffold` completed on compiler-studio plan loop.
