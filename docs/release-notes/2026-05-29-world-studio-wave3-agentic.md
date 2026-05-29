# World Studio wave 3 — agent pipeline + MCP stdio stub (2026-05-29)

## Summary

Consolidates wave 2 capture (cherry-picked) with agentic depth: `studio_agent_run_next` invokes real in-process MCP dispatch; `li-studio-ai` bridges lillm + agent pipeline; MCP stdio transport stub for WP-AG-03.

## Changed

| Path | Notes |
|------|-------|
| `packages/li-studio/src/lib.li` | `studio_agent_run_next` calls `studio_mcp_tool_dispatch` per step |
| `packages/li-studio-ai/src/lib.li` | MCP dispatch, lillm complete, `studio_ai_run_agent_pipeline` |
| `scripts/studio-mcp-li-engine-stub.sh` | WP-AG-03 JSON-RPC stdio scaffold (transport only) |
| Wave 2 files | Cherry-picked Li PPM capture + lillm matmul hint |

## Not changed

- Subprocess `lic check` / `lic build` execution
- `@cursor/sdk` network transport
- C paint host deletion (Step 4)

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_agentic_run.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_agent_pipeline.li
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./scripts/studio-mcp-li-engine-stub.sh
```
