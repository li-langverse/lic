# Release notes: 2026-05-25 — studio-mcp-lis-server

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `feat/studio-mcp-lis-server`  
**PH / REQ:** PH-AGENT-1 (lis MCP scaffold, post #252)  
**Author:** agent

---

## Summary (one sentence)

Adds a stdio JSON-RPC `lis mcp li-engine` shell stub registering eight Studio MCP tools, subprocess dispatch via `studio_mcp_tool_dispatch` evidence (`lic check studio_mcp_extended.li`), and `smoke-studio-mcp-lis-stub.sh`.

## Agent continuation (required)

1. **Read:** `docs/game-dev/studio-mcp-lis-server.md`, `docs/game-dev/studio-mcp-tools.md`, `scripts/studio-mcp-lis-stub.sh`, `packages/li-studio/src/lib.li` (`studio_mcp_tool_dispatch`).
2. **Run:** `./scripts/build.sh` (if needed); `./scripts/smoke-studio-mcp-lis-stub.sh`; `lic check packages/li-studio/li-tests/smoke/studio_mcp_extended.li`.
3. **Then:** implement native `lis mcp li-engine` with the same eight tool names; wire real `chem_dft_run` / `am_export_print` handlers; attach `@cursor/sdk` per `specs/studio-cursor-sdk-rfc.md`.
4. **Blocked on:** `lis` MCP binary and HTTP transport — **none** for this stub merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `scripts/studio-mcp-lis-stub.sh` / `.py` | MCP stdio server: `initialize`, `tools/list` (8 tools), `tools/call` | `smoke-studio-mcp-lis-stub.sh` |
| `scripts/studio-mcp-lis-dispatch.sh` | Subprocess dispatch JSON; `lic check` on `studio_mcp_extended.li` | dispatch `tool_id` / `status` / `result_code` |
| `scripts/smoke-studio-mcp-lis-stub.sh` | Lists eight tools; `chem_dft_run` + invalid tool dispatch | `scripts/ci.sh`, `check-master-plan-gates.sh` |
| `docs/game-dev/studio-mcp-lis-server.md` | Stub install, Cursor config example, dispatch JSON | agent-readable |
| `docs/game-dev/studio-mcp-tools.md` | Link to lis stub doc | cross-ref |

## Not changed (scope fence)

- `packages/li-studio/src/lib.li` — `studio_mcp_tool_dispatch` logic unchanged from #252
- `runtime/li_rt.c` tool name table — unchanged
- `lis` Rust/Node MCP server binary — **not** added
- MCP HTTP / SSE — **not** implemented
- `@cursor/sdk` wiring in lic repo — consumer config only
- LLVM / httpd / tier5 / proof-db — **not** touched

## Breaking / Security / Performance / Downstream

- **Breaking:** None — new scripts only.
- **Security:** N/A — stdio stub, no listen socket, no secrets in repo.
- **Performance:** N/A — smoke runs one `lic check` per dispatch call.
- **Downstream:** Cursor agents point `mcpServers.li-studio-engine` at `scripts/studio-mcp-lis-stub.sh` until `lis` ships.
