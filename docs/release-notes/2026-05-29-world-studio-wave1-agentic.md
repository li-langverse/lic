# World Studio wave 1 — agentic bridge (2026-05-29)

## Summary

Continues the battle plan after merge queue (#356, #366, #368, #370): `li-studio-ai` now delegates MCP tools to `li-studio` and routes `studio_ai_complete` through `li-llm` fixture weights.

## Changed

| Path | Notes |
|------|-------|
| `packages/li-studio-ai/src/lib.li` | `studio_ai_mcp_dispatch` → `studio_mcp_tool_dispatch_arg`; `studio_ai_complete` → `llm_generate`; `studio_ai_agent_run_tick` |
| `packages/li-studio-ai/li-tests/smoke/studio_ai_mcp_dispatch.li` | Viewport + particle MCP smokes |
| `packages/li-studio-ai/li-tests/smoke/studio_ai_complete.li` | lillm fixture generate smoke |
| `docs/game-dev/specs/c-host-retirement-plan.md` | #356 merged; Step 1 active |
| `docs/game-dev/specs/studio-cursor-sdk-rfc.md` | #370 merged; WP-AG-02 wave 1 |

## Not changed

- C paint hosts still present (`studio_shell_paint_fb.c`) — Step 4 deletion pending wgpu readback
- `lis mcp li-engine` HTTP server (WP-AG-03)
- Real patch write + `lic check --format=json` loop

## Next

1. Step 1 C-host retirement: `li-studio-demo` capture path
2. WP-LLM-05 CPU matmul for real forward
3. WP-AG-03 `lis mcp li-engine`
