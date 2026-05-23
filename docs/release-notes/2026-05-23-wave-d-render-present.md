# Release notes: wave-d-07 `li-render` present/swapchain (2026-05-23)

## Summary

**wave-d-07-render-present:** first **`import render`** package with swapchain descriptor types, acquire/present stubs, and composable smoke (`workload_class=stub`).

## Changes

- `packages/li-render/` — scaffold via `li-new-package`; `import_name = "render"`; `render_workload_class_stub`
- `packages/li-render/src/lib.li` — `SwapchainDesc`, `PresentFrame`, `render_present_swapchain_smoke_entry`
- `li-tests/composable/import_render_present_swapchain_smoke.li` — `compile_open_ok`
- `li-tests/render_present/import_render_present_smoke_entry.li` — `verify_open_ok`
- `packages/li.toml` — workspace member `li-render`

## Plan

Marks `wave-d-07-render-present` completed on compiler-studio plan loop.
