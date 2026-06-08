# Swarm gap orchestration — UX dimension audit

**Goal id:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `9b512426`  
**Date:** 2026-06-06  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Publish target:** `research-findings/whitepapers/2026-05/swarm_coverage/` (staging in lic until repo available)

---

## Abstract

This pass audits swarm health through the **UX lens** for goal `swarm_coverage`: studio UI plan debt, visualization benchmark honesty, and orchestration of `ui_ux` signals into the gap registry without reviving retired systemd plan loops.

---

## Executive summary

1. Ecosystem grade **D** (64.8) — not unattended-safe.
2. Studio UI plan loop **16/18 complete**; 2 UX todos remain (palette latency, GPU fail recovery).
3. Gap registry tracks UX work as **`plan_debt`** under `studio-ui-ux` runner — no dedicated `ui_ux` gap_kind rows yet.
4. **96 benchmark catalog rows unknown**, including all visualization workloads — UX perf evidence gap.
5. Gap ingest/apply **blocked** by script bug + missing PyYAML — registry stale since 2026-05-31.
6. Route UX work via `gui_ux_tester` (`ui_ux_quality` goal) and async implement lane, not `studio-ui-ux` systemd loop.

---

## Studio UI/UX plan status

Source: `lic/data/goal-directed-agents/snapshot.json` runner `studio-ui-ux`

| Metric | Value |
|--------|-------|
| Runner state | Stopped (`supervisor off`) |
| Plan completed | 16/18 todos done |
| Pending | `studio-ux-16-palette-search-latency`, `studio-ux-17-gpu-fail-recovery` |

Completed highlights (UX-relevant):

- Agent chrome (task status, cancel, error strip) — PH UX-06
- Bench registry + memory budget gates
- Native SDL CI capture + wgpu readback path

---

## Gap registry UX rows

| Gap id | Kind | Handoff |
|--------|------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | plan_debt | gui_ux_tester |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | plan_debt | gui_ux_tester |
| `gap-plan-pending-studio-ui-ux-studio-ux-21-wgpu-swapchain-gpu-runner` | plan_debt | implementation_gaps |
| `gap-plan-pending-studio-ui-ux-studio-ux-24-gpu-runner-deps` | plan_debt | ci_maintainer |
| `gap-vertical-stub-scientific-viz` | competitor_feature | numerics_researcher, gui_ux_tester |

---

## Visualization benchmark honesty

From `agent-briefing.json` ecosystem audit — all viz workloads **unknown**:

- `viz_colormap`, `viz_decimate`, `viz_inspector_panels`, `viz_linked_views`
- `viz_marching_cubes`, `viz_pipeline_graph`, `viz_resample`

**Recommendation:** Either register honest stub rows in `verticals.toml` or add tier-1/tier-2 bench harnesses before claiming viz parity. Aligns with proof → easy → fast pillar order.

---

## Swarm orchestration recommendations

1. Fix `lic/scripts/swarm-gap-ingest.py` L229 syntax error.
2. Install PyYAML in runner environment for gap apply.
3. Enqueue `gui_ux_tester` on `ui_ux_quality` cadence (48h).
4. Hand off studio-ux-16/17 to `code_implementer` after UX audit defines acceptance bars.
5. Close `orch-r4-ui-ux-signals` in swarm-observer plan loop on next ingest.

---

## Deferred

- Publish to research-findings repo (not mounted in this workspace).
- Full gui_ux_tester SOTA comparison run (separate agent invocation).
- Viz benchmark implementation (product/numerics scope).

---

## Evidence index

| Path | Role |
|------|------|
| `benchmarks/data/latest/ecosystem-quality-report.json` | Grade D scorecard |
| `benchmarks/data/latest/agent-briefing.json` | Briefing + viz unknowns |
| `lic/data/swarm-gap-registry/registry.yaml` | Gap taxonomy |
| `lic/data/goal-directed-agents/snapshot.json` | Studio plan state |
| `li-cursor-agents/data/runs/swarm_observer-1780733386009.md` | Meta audit digest |
| `lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r4-ui-ux-signals-9b512426.md` | orch-r4 completion |
