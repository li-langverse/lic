# Release notes: 2026-06-09 — vision-llm-agent-manifest-ci

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** **Vision-LLM** (master plan tracker v0)  
**Issue:** [#19](https://github.com/li-langverse/lic/issues/19)

---

## Summary

Completes Vision-LLM v0 agent manifest CI: wires `gen-li-agent-manifest.sh` in `scripts/ci.sh`, extends `agent_manifest_smoke.sh` to assert generated `li-agent.json` and `.cursor/AGENTS.generated.md`, and documents deferred non-goals for structured `fix_hint` patches.

## Agent continuation

1. Read: `docs/ecosystem/li-agent-manifest.toml`, `docs/superpowers/specs/2026-05-16-li-llm-first-design.md`.
2. Run: `./li-tests/tooling/agent_manifest_smoke.sh && ./li-tests/tooling/diagnose_json_smoke.sh`
3. Then: `lic edit --patch=json` spec implementation (v2 backlog).

## Changed

| Area | What | Evidence |
|------|------|----------|
| Vision-LLM | `gen-li-agent-manifest.sh` wired in CI Vision-LLM phase | `scripts/ci.sh` |
| Vision-LLM | Smoke asserts `li-agent.json` + `AGENTS.generated.md` link test manifest | `li-tests/tooling/agent_manifest_smoke.sh` |
| Vision-LLM | `lic-fix-suggest.sh` v0 + deferred `fix_hint` non-goals | `docs/superpowers/specs/2026-05-16-li-llm-first-design.md` |
| Tracker | Vision-LLM v0 row checked | `docs/superpowers/plans/2026-05-14-li-master-plan.md` |

## Not changed

- `lic edit --patch=json` — still spec-only (v2 backlog).
- Structured `fix_hint` patch objects in compiler output — deferred non-goal.

## CHANGELOG entry

```markdown
### Added
- **Vision-LLM (v0):** `gen-li-agent-manifest.sh` wired in CI; agent manifest smoke asserts `li-agent.json` — `docs/release-notes/2026-06-09-vision-llm-agent-manifest-ci.md`.
```
