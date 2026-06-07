# Release notes: 2026-06-07 — Vision-LLM manifest ship gate

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** **Vision-LLM** (master plan tracker v1 gate)  
**Issue:** [#464](https://github.com/li-langverse/lic/issues/464)

---

## Summary

Closes the Vision-LLM v1 agent diagnostics ship gate: documents the exit checklist, wires `gen-li-agent-manifest.sh` into CI with a smoke test, and marks the master plan tracker row with test/manifest evidence.

## Agent continuation

1. Read: `docs/superpowers/specs/2026-05-16-li-llm-first-design.md` (exit gate section).
2. Run: `./scripts/build.sh && ./li-tests/tooling/diagnose_json_smoke.sh && ./li-tests/tooling/gen_li_agent_manifest_smoke.sh && ./li-tests/tooling/agent_manifest_smoke.sh`
3. Then: `lic edit --patch=json` spec implementation; structured `fix_hint`; Studio WP-AG-04 eval loop.
4. Blocked on: terse-syntax RFC needs human approval (pillar 1).

## Changed

| Area | What | Evidence |
|------|------|----------|
| Vision-LLM | Exit gate checklist in LLM-first spec | `docs/superpowers/specs/2026-05-16-li-llm-first-design.md` |
| Vision-LLM | `gen_li_agent_manifest_smoke.sh` + CI wiring | `li-tests/tooling/gen_li_agent_manifest_smoke.sh`, `scripts/ci.sh` |
| Vision-LLM | Manifest TOML exports table | `docs/ecosystem/li-agent-manifest.toml` |
| Tracker | Vision-LLM row `[x]` with smoke paths | `docs/superpowers/plans/2026-05-14-li-master-plan.md` |

## Not changed

- `lic check` / `lic diagnose` compiler output — smoke-only gate wiring.
- `lic edit --patch=json` — still spec-only.
- `packages/li-studio-ai` WP-AG-04 eval loop — separate backlog.

## Breaking changes

None.

## CHANGELOG entry

```markdown
### Added
- **Vision-LLM v1 gate:** `gen_li_agent_manifest_smoke.sh` in CI; exit gate checklist — `docs/release-notes/2026-06-07-vision-llm-manifest-ship-gate.md`.
```
