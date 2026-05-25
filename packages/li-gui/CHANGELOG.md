# Changelog

## [Unreleased]

### Added

- **Viewport region** — `ViewportRegion` + `gui_viewport_region_from_layout` from `li-ui` shell layout IR.
- **Panel switch timing** — `PanelSwitchTiming`, `GuiPanelState`, `gui_panel_switch_to` hooks with PH-UX budget (`studio_panel_transition_ms` ≤ 100).
- **Bench hook** — `bench/panel_switch.toml` for `bench-studio-viewport-perf.sh` / `studio-ui.toml` registry.
- **Paint expansion** — `gui_paint_studio_shell_chrome` delegates to `li-ui` aggregate stub; decomposed dock/timeline/inspector paint lives in `li-studio`.
- **Panel switch** — `gui_panel_switch_to` avoids move of `elapsed_ms`/`region` args (studio-ux-05).
