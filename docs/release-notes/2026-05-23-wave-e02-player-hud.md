# Release notes: wave-e-02 `li-player` gui HUD (2026-05-23)

## Summary

**wave-e-02-player-hud:** first **`import player`** package loads **`import gui`** HUD overlay paint IR and pairs with **`import render`** viewport swapchain (`workload_class=stub`).

## Changes

- `packages/li-player/` — scaffold via `li-new-package`; `import_name = "player"`; `player_workload_class_stub`
- `packages/li-player/src/lib.li` — `player_load_gui_hud_hd`, `player_load_gui_hud_smoke_entry`
- `packages/li-gui/src/lib.li` — `PlayerHudLayout`, `gui_hud_layout_hd`
- `packages/li.toml` — workspace member `li-player`
- `li-tests/composable/import_player_gui_hud.li`, `li-tests/player_hud/import_player_gui_hud_smoke_entry.li`
