# Release notes: AL-9 `li-gui` scaffold (2026-05-23)

## Summary

First **`import gui`** package: `UiDocument`, paint IR, studio shell layout (UX-02), and inspector row stubs (UX-04).

## Changes

- `packages/li-gui/` — scaffold via `li-new-package`; `import_name = "gui"`
- `packages/li-gui/src/lib.li` — `StudioShell`, `PaintCmd`, `gui_hit_test_rect`, ParaView-style inspector section IDs
- `li-tests/composable/import_gui_studio_shell.li` — cross-checks widths with `adaptive_layout_hd()` on `li-ui`
- `packages/li.toml` — workspace member `li-gui`

## Competitive intel

- **UX-02:** `studio_shell_layout_hd()` — sidebar/main/inspector ~22% / ~56% / ~22% at 1280×720
- **UX-04:** `inspector_section_count()` + `InspectorRow` (Properties / Display / View)

## Plan

Marks `wave-d-gui-scaffold` completed on compiler-studio plan loop.
