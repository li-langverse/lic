# Changelog

## [Unreleased]

### Added

- **WP-SIM-06 studio.toml engine/export** — `StudioExportConfig`, cumulative `studio_toml_parse_line` / `studio_toml_parsed_config`, `determinism_tier` → `output_detail` via `studio_apply_config_to_sim`; fixture `examples/verticals/sim_additive/studio.toml`; smoke `studio_toml_engine_export.li` in plan gates.
- **Native agent shell bench (UX-06, studio-ux-23)** — `studio_shell_agent_bench_native` wires shell compose + agent paint for stream tick/cancel bench hook.
- **Native palette shell bench (UX-04, studio-ux-22)** — `studio_shell_palette_bench_native` wires shell compose + palette overlay paint for native bench hook.
- **GPU fail recovery (UX-08, studio-ux-17)** — `studio_compose_shell_gpu_fail`, `studio_paint_gpu_fail_overlay`; viewport fail strip + retry rect from `li-ui`.
- **Agent chrome (UX-06)** — `StudioAgentChromeCompose` with task states (idle/running/blocked/failed/done), cancel rect, error strip; `studio_paint_agent` + `studio_compose_shell_agent`.
- **Panel compose** — `StudioDockCompose`, `StudioTimelineCompose`, `StudioInspectorCompose` from `li-ui` shell layout.
- **Paint decomposition** — `studio_paint_dock`, `studio_paint_timeline`, `studio_paint_inspector` (playhead + track + selection header).
- **Shell frame** — `studio_shell_frame` wires compose panels with topbar, viewport grid, and agent strip.
- **Panel switch** — `studio_panel_switch_inspector` / `studio_panel_switch_timeline` on `GuiPanelState`.
