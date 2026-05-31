# Changelog

## [Unreleased]

### Added

- **W2 Compose dependency graph** — `ComposeDepGraph`, static `ComposePlan` table (`compose_dep_plan_store_at`/`compose_dep_plan_region_at`), region ids for agent/palette/dock/inspector/timeline/viewport HUD; `store_int_set_with_deps` / `store_float_set_with_deps`; smoke `compose_dep_invalidation.li`; `gui_reactive_version() == 2`.
- **W2 Reactive stores** — `StoreInt`/`StoreFloat`, `DerivedInt`/`DerivedFloat`, `ComposeInvalidation` in `src/reactive.li`; shell slot ids; `derived_int_sync_agent_progress`; smoke `reactive_store_derived.li`; `gui_reactive_version() == 1`; `li_std_gui_version` → 11. — `FlexLayout`, `GridLayout`, `PaddingLayout`, `ScrollLayout` with measure/layout procs; `flex_layout_paint`; smoke `layout_engines_flex_grid.li`; `li_std_gui_version` → 6.
- **W1 Widget protocol** — `WidgetNode`, `widget_measure`, `widget_layout`, `widget_paint`, `widget_handle_event`; kinds label/button/panel/spacer; smoke `widget_protocol_measure_layout.li`; `li_std_gui_version` → 5.
- **UX-04 palette action dispatch** — `studio_key_action_palette_exec`, `gui_studio_palette_exec_compose`, `gui_studio_palette_region_for_action`; digits 1–3 execute palette actions when open; `li_std_gui_version` → 4.
- **UX-09 keyboard-first** — `StudioKeyBinding`, `gui_handle_studio_key`, `studio_handle_studio_key`; smoke `studio_keyboard.li`.
- **UX-09 input JSON mock** — smoke `studio_keyboard_input_json.li` (probe-shaped `InputState`); host bridge in `docs/game-dev/studio-shell-input-bridge.md`.
- **UX-01 selection** — `ViewportSelection`, `gui_viewport_selection_none` / `gui_viewport_selection_rect`; `selection_active` on `ViewportRegion`.
- **Viewport region** — `ViewportRegion` + `gui_viewport_region_from_layout` from `li-ui` shell layout IR.
- **Panel switch timing** — `PanelSwitchTiming`, `GuiPanelState`, `gui_panel_switch_to` hooks with PH-UX budget (`studio_panel_transition_ms` ≤ 100).
- **Bench hook** — `bench/panel_switch.toml` for `bench-studio-viewport-perf.sh` / `studio-ui.toml` registry.
- **Paint expansion** — `gui_paint_studio_shell_chrome` delegates to `li-ui` aggregate stub; decomposed dock/timeline/inspector paint lives in `li-studio`.
- **Panel switch** — `gui_panel_switch_to` avoids move of `elapsed_ms`/`region` args (studio-ux-05).
