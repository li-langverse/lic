# Release notes: wave-d-12 command palette + agent cmd IDs (2026-05-23)

## Summary

**UX-03** command palette contexts and **UX-11** PH-AGENT command ID stubs on `import ui`, aligned rects on `import gui`, and cross-package checks in `studio_wire_gui_hd()`.

## Changes

- `packages/li-ui/src/lib.li` — `CommandPalette`, `PaletteEntry`, context IDs (viewport/graph/sim), agent cmd IDs (`lic build`, `lic check`, adaptive layout, MCP invoke)
- `packages/li-gui/src/lib.li` — `gui_palette_context_*`, `gui_agent_cmd_*`, `gui_command_palette_rect_hd()`
- `packages/li-studio/src/lib.li` — smoke + wire checks for palette/agent ID parity
- `li-tests/composable/import_ui_command_palette.li` — PH-UX palette composable

## Competitive intel

- **UX-03:** context-sensitive command sets; ⌘K overlay region on main viewport (stub)
- **UX-11:** agent mutation cmd IDs for `lic build` / `lic check` (stub; no MCP runtime)

## Plan

Marks `wave-d-12-ux-command-palette` completed on compiler-studio plan loop.
