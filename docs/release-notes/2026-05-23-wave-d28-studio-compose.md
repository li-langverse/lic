# Release notes: wave-d-28 studio compose ui+gui+render+world (2026-05-23)

## Summary

**`import studio`** public compose API wires **`import ui`** chrome, **`import gui`** paint IR, **`import render`** viewport swapchain, and **`import world`** GameWorld tick hooks.

## Changes

- `packages/li-world/` — PH-GD-2 `GameWorld` stub + scene hooks + `world_smoke_entry`
- `packages/li-render/src/lib.li` — `render_swapchain_desc_viewport(width, height)`
- `packages/li-studio/src/lib.li` — `StudioCompose`, `studio_compose_ui_gui_render_world()`, `studio_compose_smoke_entry()`; version 2
- `li-tests/composable/import_studio_compose.li` — cross-import composable
- `li-tests/studio_compose/import_studio_compose_entry.li` — closed witness
- `li-tests/composable/import_world_smoke.li` + `li-tests/world_smoke/` — world composable

## Honesty

- `workload_class=stub` on `world`, `render`, and `studio` — no UE5/Gaussian parity claims
- Viewport dims (716×720) match `studio_shell_layout_hd()` main rect; swapchain sized to viewport

## Plan

Marks `wave-d-28-studio-compose` completed on compiler-studio plan loop.
