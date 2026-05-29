# li-studio-ai

Agent orchestration layer for Li World Studio (`import studio.ai`).

## Status: **Wave 1** (partial)

Routes prompts to `llm_generate` when fixture weights load; Cursor SDK cloud fallback deferred.
Inference lives in `packages/li-llm`.

| WP | API | Status |
|----|-----|--------|
| WP-AG-02 | `studio_ai_mcp_dispatch` | **partial** — delegates to `li-studio` MCP dispatch |
| WP-AG-04 | `studio_ai_complete`, `studio_ai_apply_patch` | **partial** — lillm generate + no-op patch |
| PR #370 | `studio_ai_agent_run_tick` | bridges `StudioAgentRun` on `li-studio` |

## Verify

```bash
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_mcp_dispatch.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_complete.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_task_state.li
```

See `docs/game-dev/specs/studio-cursor-sdk-rfc.md`.
