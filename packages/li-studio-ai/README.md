# li-studio-ai

Agent orchestration layer for Li World Studio (`import studio.ai`).

## Status: **STUB** (Wave 0)

Routes prompts to `llm.generate` (local) or Cursor SDK cloud (fallback). Does **not**
implement inference — see `packages/li-llm`.

| WP | API | Status |
|----|-----|--------|
| WP-AG-02 | `studio_ai_mcp_dispatch` | stub |
| WP-AG-04 | `studio_ai_complete`, `studio_ai_apply_patch` | stub |
| PR #362 | `studio_ai_cancel_task` FSM | stub |

## Verify

```bash
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_task_state.li
```

See `docs/game-dev/specs/studio-cursor-sdk-rfc.md`.
