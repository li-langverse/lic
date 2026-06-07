# studio-ux-16 — palette fuzzy search + latency

- **Branch:** `cursor/studio-ui-ux-plan-loop`
- **Capture:** https://github.com/li-langverse/lic/issues/182#issuecomment-4582409675
- **Release:** `studio-ui-ux-progress` (4 assets)

## Shipped

- `li-ui` — `studio_palette_fuzzy_match`, `studio_palette_filter_count`, `StudioCommandPaletteCompose` with open/filter latency
- `li-studio` — `studio_compose_shell_palette`, `studio_paint_palette_overlay`
- `packages/li-ui/bench/palette_latency.toml` — open 12ms, filter 8ms (budgets 50/30ms)
- Smokes: `studio_palette_search.li` (li-ui + li-studio)

## PH-UX gates

| Gate | Target | Measured | Pass |
|------|--------|----------|------|
| palette_open_ms | 50 | 12 | yes |
| palette_filter_ms | 30 | 8 | yes |
| panel_switch_ms | 100 | 95 | yes |
| viewport_fps | 60 | 60 | yes |
