# Release notes: AL-10 `li-linalg` scaffold (2026-05-23)

## Summary

**wave-d-05-linalg-scaffold (AL-10):** first **`import linalg`** package with explicit `matmul_2x2_f32` / `matmul_2x3_f32` over compiler `@` (2i); composable + `math_linalg` smoke tests.

## Changes

- `packages/li-linalg/` — scaffold via `li-new-package`; `import_name = "linalg"`; `workload_class=stub`
- `packages/li-linalg/src/lib.li` — `matmul_*_f32`, `matmul_*_smoke_entry00` closed-form witnesses
- `li-tests/composable/import_linalg_matmul_smoke.li` — `compile_open_ok`
- `li-tests/math_linalg/import_linalg_matmul_2x2.li` — `compile_ok`
- `packages/li.toml` — workspace member `li-linalg`

## Plan

Marks `wave-d-05-linalg-scaffold` completed on compiler-studio plan loop.
