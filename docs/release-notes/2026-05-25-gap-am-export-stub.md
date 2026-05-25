# Release notes: 2026-05-25 — gap-am-export-stub

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `feat/gap-am-export-stub`  
**PH / REQ:** PH-AM (additive export stub), PH-AGENT (MCP tool #6)  
**Author:** agent

---

## Summary (one sentence)

`li-sim-additive` PH-AM export contracts (`am_export_gcode_3mf_smoke`, `am_export_require_sim_pass`) and `studio_mcp_tool_dispatch` wiring for `am_export_print` (ID 6) — builds on eight-tool MCP contracts on main; no printer I/O.

## Agent continuation (required)

1. Read: `docs/game-dev/studio-mcp-tools.md`, `packages/li-sim-additive/src/lib.li`, `packages/li-studio/src/lib.li` (`studio_mcp_tool_dispatch`).
2. Run: `lic check packages/li-sim-additive/li-tests/smoke/am_export_smoke.li`; `lic check packages/li-studio/li-tests/smoke/studio_mcp_am_export_dispatch.li`.
3. Then: PH-AM-1 — real 3MF/G-code writers + `require_sim_pass` gate on last `SimRunResult`; register `am_export_print` in `lis mcp li-engine`.
4. Blocked on: slicer FFI and printer send paths — **none** for this contract merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/li-sim-additive` | New package `import sim.additive`; `am_export_require_sim_pass()` → `1`; `am_export_gcode_3mf_smoke()` → `0` | `li-tests/smoke/am_export_smoke.li` |
| `packages/li-studio` | `import sim.additive`; `studio_mcp_tool_dispatch` calls `am_export_gcode_3mf_smoke` when `tool_id == studio_mcp_am_export_print()` | `li-tests/smoke/studio_mcp_am_export_dispatch.li` |
| `runtime/li_rt.c` | MCP name `am_export_print` (ID 6) | `studio_mcp_tool_from_name` round-trip |
| `docs/game-dev/studio-mcp-tools.md` | Tool row + dispatch API | agent-readable contract |

## Not changed (scope fence)

- `lis` MCP HTTP server — **not** implemented.
- `chem_dft_run`, `studio_adaptive_layout` MCP tools — **not** in this PR.
- Real G-code/3MF file writers, thermal sim, voxel occupancy — **not** in this PR.
- `li_std_studio_version` — remains **6**.
- Compiler tier-1 / httpd / proof-db — **not** touched.

## Breaking / Security / Performance / Downstream

- **Breaking:** N/A — `studio_mcp_tool_count()` remains **8** on main; this PR only adds export smoke wiring.
- **Security:** N/A — stub dispatch, no network or filesystem export.
- **Performance:** N/A — O(1) smoke return.
- **Downstream:** Studio agents on `sim_additive` profile should use MCP name `am_export_print` before AGENT-1 HTTP registration.
