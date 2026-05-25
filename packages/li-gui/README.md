# li-gui

Native Li Studio GUI layer: viewport region extraction, panel-switch timing hooks, and paint-IR expansion over `li-ui` shell composables.

## Viewport (UX-01)

- `ViewportSelection` — optional marquee (`active=0` none; `active=1` + `rect` + `depth_cue`).
- `gui_viewport_region_from_layout` — no selection; `gui_viewport_region_from_layout_with_selection` — exposes `selection_active` on `ViewportRegion`.

Import: `import gui`
