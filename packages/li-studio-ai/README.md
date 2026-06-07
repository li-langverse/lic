# li-studio-ai

Agent orchestration layer for Li World Studio (`import studio.ai`).

## Status: **partial** (Wave 1 — WP-AG-03/04)

Routes prompts to `llm.generate` (local fixture weights) or honest empty (cloud stub).
Inference lives in `packages/li-llm`.

| WP | API | Status |
|----|-----|--------|
| WP-AG-02 | `studio_ai_mcp_dispatch` | **done** |
| WP-AG-03 | MCP stdio bridge | **done** (via `li-studio` server handlers) |
| WP-AG-04 | `studio_ai_complete`, `studio_ai_apply_patch`, `studio_ai_apply_patch_loop` | **done** (mock lic check + retry) |
| PR #362 | `studio_ai_cancel_task` FSM | partial |

## Verify

```bash
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_apply_patch_loop.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_mcp_dispatch.li
```

See `docs/game-dev/specs/studio-cursor-sdk-rfc.md`.
