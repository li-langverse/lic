# Release notes: PH-UX adaptive layout composable (2026-05-23)

## Summary

First **studio.adaptive** slice on `li-ui`: drug-discovery stage layout roles, fixed 1280×720 panel rects, and composable import test.

## Changes

- `packages/li-ui/src/lib.li` — `AdaptiveLayout`, `adaptive_layout_hd()`, `adaptive_panel_rect_ml()`, layout role helpers
- `li-tests/composable/import_ui_adaptive_layout.li` — `compile_ok` (wave-e-01: `rect_contains` 0/1 VC witness + sidebar hit-test)

## Plan

Marks `studio-ph-ux-slice` completed on compiler-studio plan loop.
