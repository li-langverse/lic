# li-studio-ai

Agent orchestration layer for Li World Studio (`import studio.ai`).

## Status: **partial** (Wave 1 — WP-AG-03/04)

Routes prompts to `llm.generate` (local fixture weights) or honest `"."` stub when weights absent.
Inference lives in `packages/li-llm`.

| WP | API | Status |
|----|-----|--------|
| WP-AG-02 | `studio_ai_mcp_dispatch` | **done** |
| WP-AG-03 | MCP stdio bridge | **done** (via `li-studio` server handlers) |
| WP-AG-04 | `studio_ai_complete`, `studio_ai_apply_patch`, `studio_ai_apply_patch_loop` | **done** (in-process lic check + retry) |
| WP-AG-06 | `studio_ai_patch_eval_*` | **done** (≥70% fix-rate gate) |
| PR #362 | `studio_ai_cancel_task` FSM | partial |

**Vision-LLM gate D:** apply_patch → lic check → retry loop is non-stub; `studio_ai_complete` remains fixture-bound until local weights load. See [Done gates](../../docs/superpowers/plans/2026-06-07-vision-llm-done-gates.md).

## Verify

```bash
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_apply_patch_loop.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_patch_eval.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_mcp_dispatch.li
```

See `docs/game-dev/specs/studio-cursor-sdk-rfc.md`.
