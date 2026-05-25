# Studio MCP `lis` server stub (PH-AGENT-1 scaffold)

**Status:** AGENT-1 subprocess stub (post [#252](https://github.com/li-langverse/lic/pull/252))  
**Contracts:** [studio-mcp-tools.md](studio-mcp-tools.md)  
**Vision:** [world-studio-vision.md](world-studio-vision.md) §18 — `lis mcp li-engine`

## Purpose

PR [#252](https://github.com/li-langverse/lic/pull/252) added eight Studio MCP tool IDs and `studio_mcp_tool_dispatch` in `packages/li-studio`. This slice adds a **stdio JSON-RPC MCP stub** so Cursor / `@cursor/sdk` can attach a server named `li-studio-engine` before the real `lis` binary implements HTTP transport.

No secrets, no network listen — stdin/stdout only.

## Registered tools (8)

| MCP `name` | `studio_mcp_*` ID | Notes |
|------------|-------------------|--------|
| `world_scaffold` | 1 | Stub dispatch |
| `sim_set_profile` | 2 | Stub dispatch |
| `lic_check` | 3 | Stub dispatch |
| `lic_build` | 4 | Proof gate (stub) |
| `publish_bundle` | 5 | Stub dispatch |
| `am_export_print` | 6 | Gap #6 stub |
| `chem_dft_run` | 7 | Gap #7 stub |
| `studio_adaptive_layout` | 8 | Gap #7 stub |

Name ↔ ID table matches `runtime/li_rt.c` (`li_rt_studio_mcp_tool_match_name`).

## Scripts

| Path | Role |
|------|------|
| `scripts/studio-mcp-lis-stub.sh` | MCP server launcher (stdio JSON-RPC) |
| `scripts/studio-mcp-lis-stub.py` | MCP protocol loop (`initialize`, `tools/list`, `tools/call`) |
| `scripts/studio-mcp-lis-dispatch.sh` | Subprocess: `lic check` on `studio_mcp_extended.li`, emit dispatch JSON |
| `scripts/smoke-studio-mcp-lis-stub.sh` | Smoke: eight tools listed + `chem_dft_run` dispatch |

### Dispatch JSON (`tools/call` text content)

```json
{"tool_id": 7, "status": 2, "result_code": 0, "mcp_name": "chem_dft_run", "evidence": "lic_check_studio_mcp_extended"}
```

When `lic check packages/li-studio/li-tests/smoke/studio_mcp_extended.li` is green, `evidence` is `lic_check_studio_mcp_extended` (proves `studio_mcp_tool_dispatch` in-tree). Otherwise the stub mirrors dispatch semantics in shell (`shell_dispatch_lic_check_skipped`) until `import lig.present` resolves on `main`.

- `status` **2** = `studio_mcp_tool_status_ok`
- `status` **3** = `studio_mcp_tool_status_failed`
- `result_code` **0** = `studio_mcp_tool_result_ok`
- `result_code` **2** = `studio_mcp_tool_result_err_io`

## Cursor MCP config (example)

```json
{
  "mcpServers": {
    "li-studio-engine": {
      "command": "/absolute/path/to/lic/scripts/studio-mcp-lis-stub.sh",
      "args": []
    }
  }
}
```

Use the repo checkout path; do not commit machine-specific paths into tracked config.

## Run / verify

```bash
./scripts/build.sh
chmod +x scripts/studio-mcp-lis-*.sh scripts/smoke-studio-mcp-lis-stub.sh
./scripts/smoke-studio-mcp-lis-stub.sh
lic check packages/li-studio/li-tests/smoke/studio_mcp_extended.li
```

## Not in this slice

- `lis mcp li-engine` native binary — use shell stub until `lis` lands
- MCP HTTP / SSE transport
- Real tool execution
- `@cursor/sdk` session wiring in lic — consumer config only

## Next (AGENT-1+)

1. Register the same eight names in `lis mcp li-engine`.
2. Replace stub `tools/call` with real Studio / `li-chem` handlers.
3. Keep `studio_mcp_tool_dispatch` semantics aligned with MCP responses.
