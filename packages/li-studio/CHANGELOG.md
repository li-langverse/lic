# Changelog

## [Unreleased]

### Added

- **Timeline playback (UX-02)** — `studio_timeline_playing`, `studio_timeline_toggle_play`, `studio_timeline_tick_frame` (+0.01 playhead/frame, cap 1.0); `play_btn_rect` + expanded timeline paint; smoke `studio_timeline_playback.li`.
- **Inspector fields (UX-03)** — `StudioInspectorField` + `studio_compose_inspector_selected` (≥2 label/value rows); empty path uses `studio_compose_empty_inspector`; smoke `studio_inspector_fields.li`.
- **Command palette (UX-04)** — `StudioCommandPaletteCompose` on `StudioShellCompose`; `studio_compose_shell_palette`, `studio_paint_palette_overlay`, `studio_handle_studio_key` / Cmd+K via `li-gui`; smoke `studio_command_palette.li` + `packages/li-ui` `studio_palette.li`.
- **MCP tool contracts (PH-AGENT / AGENT-0)** — `studio_mcp_*` tool IDs, `studio_mcp_tool_name` / `from_name`, `StudioAgentToolRequest`, `docs/game-dev/studio-mcp-tools.md`, smoke `studio_mcp_tools.li`.
- **Runtime profiles (UX-05 / PH-SIM scaffold)** — `studio_profile_*` constants, `studio_profile_from_name`, `studio_parse_toml_profile_line`, `StudioProjectConfig`, topbar profile chip paint, `fixtures/studio.toml`.
- **Empty states (UX-07)** — `studio_compose_empty_inspector`, `studio_compose_empty_viewport`, `studio_empty_state_for_region`; muted placeholder paint with honest inspector/viewport cmd counts; shell wires empty paths when `has_selection == 0` or `scene_entity_count == 0`.
- **Agent chrome gap-close (UX-06)** — `StudioAgentProgress`, `agent_context_label` + `context_rect`, failed `retry_hint_rect` (stroke), `studio_agent_last_action_reversible()` stub; paint cmd counts per state/context.
- **Agent chrome (UX-06)** — `StudioAgentChromeCompose` with task states (idle/running/blocked/failed/done), cancel rect, error strip; `studio_paint_agent` + `studio_compose_shell_agent`.
- **Panel compose** — `StudioDockCompose`, `StudioTimelineCompose`, `StudioInspectorCompose` from `li-ui` shell layout.
- **Paint decomposition** — `studio_paint_dock`, `studio_paint_timeline`, `studio_paint_inspector` (playhead + track + selection header).
- **Shell frame** — `studio_shell_frame` wires compose panels with topbar, viewport grid, and agent strip.
- **Panel switch** — `studio_panel_switch_inspector` / `studio_panel_switch_timeline` on `GuiPanelState`.
