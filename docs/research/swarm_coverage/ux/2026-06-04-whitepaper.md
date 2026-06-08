# Swarm coverage — UX dimension (2026-06-04)

**Goal id:** `swarm_coverage` · **Worker:** `77c8a24d`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/` (staging in `lic` until repo mounted)

## Summary

Swarm gap orchestration for the UX lens shows **strong local progress** on Compiler Studio (`studio-ui-ux` plan loop completed through wave-4) but **weak control-plane truth**: the goal-directed snapshot and swarm-gap registry still expose `studio-ux-16/17` as open `plan_debt`, and gap-apply cannot patch the studio plan backlog because `lic-studio-ui` is not mounted in the org-research Job.

Ecosystem quality is **grade D (66.3)** with **`unattended_safe: false`**. The swarm cannot run fully unattended until CI on metrics PRs clears, briefing heap aligns with security P0, and control-plane artifacts persist across Job restarts.

## Evidence paths

- `lic/data/studio-ui-ux-plan-loop/state.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/agent-briefing.json`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-04-orch-r4-ui-ux-signals.md`

## Recommendations

1. Refresh goal-directed snapshot on the host runner; close stale studio-ui registry rows.
2. Dispatch `gui_ux_tester` under `ui_ux_quality` for harness gaps in `gui-ux-quality-handoff.md`.
3. Merge ingest fix + bake PyYAML so gap ingest/apply is reliable in CI Jobs.
