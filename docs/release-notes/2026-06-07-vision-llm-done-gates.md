# Release notes: 2026-06-07 — vision-llm-done-gates

**Issue:** [#425](https://github.com/li-langverse/lic/issues/425)  
**PH / REQ:** **Vision-LLM** (master plan tracker partial)

## Summary

Formal **Done** exit gates (A–E) for master-plan **Vision-LLM**: manifest schema, test export CI, diagnostic smokes, studio-ai handoff, tracker closure. Cross-links in llm-first spec + agent-handover docs. Master plan L476 stays `[ ]` until gates A–D green.

## Verify

1. Read: `docs/superpowers/plans/2026-06-07-vision-llm-done-gates.md`
2. Run: `./scripts/build.sh && ./li-tests/tooling/diagnose_json_smoke.sh && ./li-tests/tooling/check_workspace_cache_smoke.sh && ./li-tests/tooling/agent_manifest_smoke.sh`

## Changes

| Area | Change | Paths |
|------|--------|-------|
| Plan | Five exit gates A–E with file/test cites | `docs/superpowers/plans/2026-06-07-vision-llm-done-gates.md` |
| Spec | Done checklist table | `docs/superpowers/specs/2026-05-16-li-llm-first-design.md` |
| Handover | Gate summary + CI-backed manifest note | `docs/ecosystem/agent-handover-formats.md` |
| Cross-links | Vision-LLM row links plan + #464 | `docs/ecosystem/plan-cross-links.md` |
| Studio | Gate D README linkage | `packages/li-studio-ai/README.md` |

## Gate status

| Gate | Status |
|------|--------|
| A (manifest CI) | Partial — #464 / PR #1056 |
| B (test export) | Green |
| C (diagnostics) | Green |
| D (studio-ai) | Partial — doc linkage done; fixture-bound completion open |
| E (tracker) | Blocked — flip L476 when A–D green |
