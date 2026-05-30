# li-studio-ai

Agent orchestration layer for Li World Studio (`import studio.ai`).

## Status: **Wave 3** (partial)

Routes prompts to `llm_generate` when fixture weights load. MCP tools delegate to `li-studio` in-process.

| WP | API | Status |
|----|-----|--------|
| WP-AG-02 | `studio_ai_mcp_dispatch` | **partial** |
| WP-AG-03 | `scripts/studio-mcp-li-engine-stub.sh` | **partial** (stdio transport) |
| WP-AG-04 | `studio_ai_complete`, `studio_ai_run_agent_pipeline` | **partial** |

## Verify

```bash
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_mcp_dispatch.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_agent_pipeline.li
lic check packages/li-studio/li-tests/smoke/studio_agentic_run.li
```

See `docs/game-dev/specs/studio-cursor-sdk-rfc.md`.
