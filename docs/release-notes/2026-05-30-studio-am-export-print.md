# Release: Studio AM export print (WP-AM-03, WP-UX-16)

**Date:** 2026-05-30  
**PH / REQ:** PH-AM AM-3, PH-UX UX-16  
**Branch:** `cursor/world-studio-master-plan-loop`

## Summary

Additive profile export moves from MCP format stubs to `sim.export.print` with a native three-click wizard (Review → Pre-flight → Export/Print).

## Proof

| Gate | Command |
|------|---------|
| sim export | `lic check packages/li-sim-additive/li-tests/smoke/sim_export_print.li` |
| studio wizard | `lic check packages/li-studio/li-tests/smoke/studio_am_export_three_click.li` |
| plan gates | `./scripts/world-studio-plan-gates.sh` |

## API

- `sim_export_print(format, sim_pass, printer_slot, detail)` → `AmExportPrintResult`
- `studio_am_export_three_click_flow(cfg, sim_out, fmt)` — exactly 3 wizard clicks
- `studio_mcp_am_export_print` dispatch calls `sim_export_print` before returning OK
