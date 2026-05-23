# Release notes: wave-d-10 studio chrome + gui wire (2026-05-23)

## Summary

**`import studio`** package wires **`import gui`** shell layout to **`import ui`** studio chrome hooks (UX-02).

## Changes

- `packages/li-ui/src/lib.li` — `StudioChrome`, `StudioChromeHook`, hook IDs (menubar/toolbar/statusbar/command palette/agent panel)
- `packages/li-studio/` — `studio_wire_gui_hd()`, `StudioWire`, `import gui` + `import ui` in package lib
- `li-tests/composable/import_studio_gui_wire.li` — cross-import composable
- `li-tests/studio_wire/import_studio_gui_wire_entry.li` — closed witness
- `packages/li.toml` — workspace member `li-studio`

## Competitive intel

- **UX-02:** chrome hooks attach to `adaptive_layout_hd()` regions; widths match `studio_shell_layout_hd()`
- **UX-03/11:** command palette + agent panel hook IDs (stub; no runtime)

## Plan

Marks `wave-d-10-ui-studio-wire` completed on compiler-studio plan loop.
