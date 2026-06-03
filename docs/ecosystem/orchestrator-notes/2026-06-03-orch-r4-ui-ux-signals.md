# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-03  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Org research dimension:** `ux` (worker `8101a93a`)  
**Work item:** Wire UI/UX gap signals from `studio-ui-ux` loop + briefing into swarm registry, research goals, and operator-facing health — **no new lic systemd loops**

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (69.8); `unattended_safe: false` |
| `orch-r4` | **Completed (orchestration)** — UX signal map + stale-row reconcile documented |
| Studio loop | **25 todos completed** including `studio-ux-16/17/21/24` |
| Registry drift | **High** — same todos still `open` in `swarm-gap-registry/registry.yaml` |
| Operator UX | Empty CP disk cache + DB down → dashboard blind |
| Unattended? | **No** — gap ingest broken; heap not dispatching briefing P0 agents |

Evidence: `benchmarks/data/latest/ecosystem-quality-report.json`, `lic/data/studio-ui-ux-plan-loop/state.json`, `lic/data/swarm-gap-registry/registry.yaml`, `benchmarks/data/latest/agent-briefing.json`.

---

## UX signal taxonomy (`gap_kind: ui_ux` / studio plan_debt)

| Signal source | Discoverer | Swarm route | Notes |
|---------------|------------|-------------|-------|
| `studio-ui-ux` plan todos | `plan_verifier` | Patch `2026-05-24-studio-ui-ux-plan-loop.md`; handoff `gui_ux_tester` | Do **not** install new systemd loop — use agents CP research lane |
| Failed studio PR CI | briefing `failed_prs` | `ui_ux_quality` → `gui_ux_tester` → `code_implementer` | e.g. `studio#67` typography FX |
| Master-plan UX gaps | lic issues | `issue_planner` | e.g. lic#575 palette + GPU recovery |
| Swarm meta UX | `orch-r4-ui-ux-signals` | `swarm_observer` / this note | Operator observability + registry sync |

---

## Reconcile: registry vs studio-ui-ux loop

| Plan todo | Registry gap id | Loop `completed_ids` | Registry action |
|-----------|-----------------|----------------------|-----------------|
| `studio-ux-16-palette-search-latency` | `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | ✅ present | **Close on next ingest** — `plan_verifier` |
| `studio-ux-17-gpu-fail-recovery` | `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | ✅ present | **Close on next ingest** |
| `studio-ux-21-wgpu-swapchain-gpu-runner` | patched in gap-actions | ✅ present | Close + keep backlog patch for audit trail |
| `studio-ux-24-gpu-runner-deps` | patched in gap-actions | ✅ present | Close + keep backlog patch |

**Root cause:** `goal-directed-agents/snapshot.json` frozen @ 2026-05-30 while `studio-ui-ux-plan-loop/state.json` advanced through 2026-05-30 evening. Gap ingest cannot refresh until `swarm-gap-ingest.py` L229 syntax is fixed.

---

## Research goal routing (async swarm — not systemd)

| Goal id | Agent | UX role |
|---------|-------|---------|
| `ui_ux_quality` | `gui_ux_tester` | Periodic studio/docs/TUI audits; handoff `code_implementer` |
| `swarm_coverage` | `swarm_observer` | Meta health + gap orchestration (this note) |
| `game_engine_ux` | `goal_researcher` | Gaming vertical UX research |

**Do not** recommend `install-goal-plan-loop-systemd.sh` for studio-ui-ux — migrated to agents control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Handoffs (with north_star_fit)

| To | Work | north_star_fit |
|----|------|----------------|
| `plan_verifier` | Resync registry closed rows for studio-ux-16/17/21/24 | ecosystem — easy operator truth |
| `gui_ux_tester` | Audit `studio#67` CI failure + capture harness regressions | ecosystem, web — easy UX |
| `issue_planner` | lic#575 tracking PR for remaining master-plan UX | provable before perf |
| `ci_maintainer` | `li-sec-agent` missing CI (briefing P0) | secure ecosystem |
| `gap_explorer` | Refresh competitor vertical stubs after ingest fix | ecosystem |

---

## Blockers (human / infra)

1. `swarm-gap-ingest.py:229` syntax — blocks all registry refresh  
2. PyYAML missing in org-research Job — blocks gap apply  
3. Control-plane DB + disk cache empty — operator dashboard UX  
4. `research-findings` not mounted — whitepaper publish deferred  

---

## Related

- Prior package sweep: `2026-05-31-orch-r3-missing-package-sweep.md`
- Swarm observer digest: `/app/data/runs/swarm_observer-1780529996077.md`
- Studio loop state: `lic/data/studio-ui-ux-plan-loop/state.json`
