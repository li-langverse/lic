# Release notes: wave-d-09 `li-assets` glTF ingest (2026-05-23)

## Summary

**wave-d-09-assets-gltf:** first **`import assets`** package with GLB/JSON ingest descriptor types, mesh stub, and composable smoke (`workload_class=stub`).

## Changes

- `packages/li-assets/` — scaffold via `li-new-package`; `import_name = "assets"`; `assets_workload_class_stub`
- `packages/li-assets/src/lib.li` — `GltfIngestDesc`, `GltfMeshStub`, `assets_gltf_ingest_stub`, `assets_gltf_import_smoke_entry`
- `li-tests/composable/import_assets_gltf_ingest_smoke.li` — `compile_open_ok`
- `li-tests/assets_gltf/import_assets_gltf_smoke_entry.li` — `verify_open_ok`
- `packages/li.toml` — workspace member `li-assets`

## Plan

Marks `wave-d-09-assets-gltf` completed on compiler-studio plan loop.
