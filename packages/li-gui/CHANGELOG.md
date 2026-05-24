# Changelog

## [Unreleased]

### Added

- **Viewport region** — `ViewportRegion` + `gui_viewport_region_from_layout` from `li-ui` shell layout IR.
- **Panel switch timing** — `PanelSwitchTiming`, `GuiPanelState`, `gui_panel_switch_to` hooks with PH-UX budget (`studio_panel_transition_ms` ≤ 100).
- **Paint expansion** — `gui_paint_studio_shell_chrome` pushes seven fill/stroke/grid ops (bridge for `li-ui` aggregate stub).
