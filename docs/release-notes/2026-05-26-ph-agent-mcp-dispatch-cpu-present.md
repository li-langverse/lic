# PH-AGENT-1 partial — MCP dispatch + CPU present host

## Summary

Wires `studio_mcp_tool_dispatch` through `li_rt_studio_mcp_dispatch` (proof gate, profile env), Li hooks for chem/adaptive layout, `STUDIO_CPU_PRESENT` CPU framebuffer path, and studio vertical bench registry hooks.

## Agent continuation

1. **Read** — `docs/game-dev/studio-mcp-tools.md`, `runtime/li_rt.c` (MCP + CPU present), `packages/li-studio/src/lib.li`.
2. **Run** — `lic check packages/li-studio/li-tests/smoke/studio_mcp_dispatch_run.li`; `STUDIO_CPU_PRESENT=1 lic check packages/li-studio/li-tests/smoke/studio_cpu_present.li`.
3. **Then** — `lis mcp li-engine` HTTP server + `@cursor/sdk` per `specs/studio-cursor-sdk-rfc.md`.
4. **Blocked on** — in-tree `lis` MCP server; wgpu-rs readback for non-CPU pixels.

## Changed

| Area | Paths |
|------|-------|
| Runtime | `li_rt_studio_mcp_dispatch`, `STUDIO_CPU_PRESENT`, proof/build state |
| Studio | `studio_mcp_tool_dispatch`, `studio_present_frame_acceptable`, version → 8 |
| Bench | `studio_mcp_dispatch.toml`, `studio_vertical_present.toml`, `studio-ui.toml` hooks |
| Smokes | `studio_mcp_dispatch_run.li`, `studio_cpu_present.li` |

## Not changed

- `lis mcp li-engine` server
- Real subprocess `lic check` / `lic build` from MCP tools
