# Release notes: wave-d-11 dock/workspace chrome UX-02 (2026-05-23)

## Summary

**UX-02** dock zones and workspace chrome on `import ui`, aligned `DockTab` helpers on `import gui`, and `studio_wire_gui_hd()` cross-package wire on `import studio`.

## Changes

- `packages/li-ui/src/lib.li` — `dock_zone_*`, `DockPanel`, `WorkspaceChrome`, `workspace_dock_panel_stage()`, `dock_panel_default_collapsed_for_role()`
- `packages/li-gui/src/lib.li` — `DockTab`, `gui_dock_zone_*`, `studio_shell_dock_zone_rect()`, `gui_dock_rect_ml()`
- `packages/li-studio/src/lib.li` — `studio_wire_gui_hd()`; smoke entry checks dock zone counts
- `li-tests/composable/import_ui_dock_workspace.li` — PH-UX dock composable
- `li-tests/studio_wire/import_studio_dock_wire_entry.li` — closed witness

## Competitive intel

- **UX-02:** collapsible stage tabs (`layout_role_*`), parent/child `DockPanel`, fixed chrome ratios via `adaptive_layout_hd()`
- **UX-07:** lab/ML stages default collapsed (`dock_panel_default_collapsed_for_role`)

## Plan

Marks `wave-d-11-ux-dock-ux02` completed on compiler-studio plan loop.
