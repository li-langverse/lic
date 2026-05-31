# li-gui

Native Li Studio GUI layer: viewport region extraction, panel-switch timing hooks, paint-IR expansion over `li-ui` shell composables, and Phase 1 **Widget protocol** (measure, layout, paint, handle_event).

## Widget protocol (W1)

Structural protocol in `lic/packages/li-gui/src/lib.li` — dispatch by `WidgetNode.kind`:

| Phase | Proc | Role |
|-------|------|------|
| measure | `widget_measure(node, constraints)` | Intrinsic size under min/max constraints |
| layout | `widget_layout(node, constraints, x, y)` | Assign bounds rect |
| paint | `widget_paint(node, frame, layout)` | Design recipes via `li-ui` PaintCmd |
| events | `widget_handle_event(node, layout, event)` | Pointer/focus dispatch |

Kinds: `widget_kind_label`, `widget_kind_button`, `widget_kind_panel`, `widget_kind_spacer`, `widget_kind_text_input`. Smoke: `li-tests/smoke/widget_protocol_measure_layout.li`.

## Base widgets (W1)

| Widget | Constructor | Notes |
|--------|-------------|-------|
| Label | `widget_node_label` | Muted text block (monospace bitmap until Phase 3 glyphs) |
| Button | `widget_node_button` | Accent chip + pointer focus |
| Panel | `widget_node_panel` | Elevated surface fill |
| TextInput | `widget_node_text_input` | Elevated field + monospace char blocks |
| ScrollArea | `scroll_area_new` | Viewport clip via `ScrollLayout`; `scroll_area_paint` / `scroll_area_handle_event` |

Smoke: `li-tests/smoke/base_widgets.li`. Version: `gui_base_widgets_version() == 1`.

## Layout engines (W1)

| Engine | Measure | Layout | Notes |
|--------|---------|--------|-------|
| Flex | `flex_layout_measure` | `flex_layout_layout` | Row/column direction, gap, up to 4 children |
| Grid | `grid_layout_measure` | `grid_layout_layout` | Equal cells, row-major child order |
| Padding | `padding_layout_measure` | `padding_layout_layout` | Insets around single child |
| Scroll | `scroll_layout_measure` | `scroll_layout_layout` | Viewport clip + scroll offset |

Smoke: `li-tests/smoke/layout_engines_flex_grid.li`. Paint helper: `flex_layout_paint`.

## Viewport (UX-01)

- `ViewportSelection` — optional marquee (`active=0` none; `active=1` + `rect` + `depth_cue`).
- `gui_viewport_region_from_layout` — no selection; `gui_viewport_region_from_layout_with_selection` — exposes `selection_active` on `ViewportRegion`.

## Keyboard (UX-09)

| Input | Action | `gui_handle_studio_key` result |
|-------|--------|----------------------------------|
| `Escape` | Close command palette when open | `studio_key_action_palette_close` (2) |
| `Cmd/Ctrl+K` | Toggle command palette | `studio_key_action_palette_toggle` (1) |
| `1`–`3` (palette open) | Execute palette action (focus inspector / timeline / agent) | `studio_key_action_palette_exec` (4) |
| `1` (palette closed) | Focus dock | `studio_key_action_region_focus` (3) |
| `2` | Focus viewport | region focus (3) |
| `3` | Focus inspector | region focus (3) |
| `4` | Focus timeline | region focus (3) |
| `5` | Focus agent strip | region focus (3) |

- `InputState.key_cmd_k`, `key_digit` — set by host/SDL ingest; defaults in `input_default()`.
- `gui_handle_studio_key(panel, input)` — panel-only palette flag.
- `gui_handle_studio_key_palette` / `studio_handle_studio_key(compose, input)` — full `StudioCommandPaletteCompose` via `studio_palette_*` in `li-ui`.

Import: `import gui`
