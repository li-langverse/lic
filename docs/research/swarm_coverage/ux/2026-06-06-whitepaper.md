# Swarm gap orchestration — UX dimension

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Agent:** `swarm_observer`  
**Run:** `1780741487896` / worker `8c52c6db`  
**Generated:** 2026-06-06T11:06Z  
**north_star_fit:** ecosystem + ai — orchestration for easy, proved UX surfaces (proof → easy → fast)

---

## Summary

The swarm gap registry carries **UX-related plan debt** under the `plan_debt` kind (not a separate `ui_ux` kind). Three rows are **stale** relative to live studio-ui loop state: `studio-ux-16`, `studio-ux-17`, and `orch-r4-ui-ux-signals`. Eight **`viz_*` benchmark IDs** remain unknown, blocking honest UX competitiveness reporting.

Ecosystem grade **D** (62.6) with `unattended_safe: false` — gap ingest/apply pipeline cannot run unattended until PyYAML is baked and ingest syntax is deployed (fixed locally this run).

## Key findings

1. **Registry drift:** Completed studio todos still marked open in `registry.yaml`.
2. **Viz coverage gap:** No tier-1/tier-2 oracle for visualization workloads.
3. **Control plane:** Missing `/app/data/control-plane/state.json` prevents programmatic observer retry accounting.
4. **Briefing alignment:** Heap recommends `ci_maintainer`, `security_auditor`, `pr_merger`; only `swarm_observer` executing in fresh workspace — expected for research lane, but merge/CI agents should follow on next coordinator tick.

## Handoffs

| Target | Action |
|--------|--------|
| `plan_verifier` | Refresh goal-directed snapshot; close completed studio-ui gap rows |
| `gui_ux_tester` | Run `ui_ux_quality` — audit viz unknowns + docs/GUI SOTA |
| `issue_planner` | Stub-honest `viz_*` catalog entries |
| `ci_maintainer` | 6 phantom repos (HTTP 404) + 34 failing PRs |

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/studio-ui-ux-plan-loop/state.json`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r4-ui-ux-signals.md`
- `/app/data/runs/swarm_observer-1780741487896.md`

**Publish target (when repo mounted):** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`
