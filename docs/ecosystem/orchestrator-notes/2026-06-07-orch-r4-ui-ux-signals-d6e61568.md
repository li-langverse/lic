# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `d6e61568`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `ux`  
**Work item:** Route UI/UX gap signals from registry → swarm goals/handoffs; operator UX for gap-apply visibility

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (63.9)**; `unattended_safe: false` |
| `orch-r4` | **Completed (orchestration)** — UX gap rows reconciled; handoffs enqueued |
| Studio UI | 4 plan todos open in registry; `studio-ux-16` shipped in tree but snapshot stale |
| Operator UX | Control-plane disk mirrors missing; gap apply invisible on dashboard |
| Unattended? | **No** — PyYAML blocks live ingest/apply; platform agents not dispatched |

Evidence: `benchmarks/data/latest/ecosystem-quality-report.json`, `lic/data/swarm-gap-registry/registry.yaml`, `data/runs/swarm_observer-1780841922772.md`.

---

## UX gap taxonomy reconcile

| `gap_kind` | Open count (registry) | UX-relevant rows | Primary handoff |
|------------|----------------------|------------------|-----------------|
| `plan_debt` | 31 | studio-ui-ux ×4, orch-r4 | `gui_ux_tester`, studio-ui implement lane |
| `competitor_feature` | 30 | scientific_viz, cinematic_* ×4, mmo_shard | `gui_ux_tester`, `goal_researcher` (game_engine_ux) |
| `missing_package` | 3 | std.plot / std.summary (dashboard static viz) | `issue_planner`, `package_architect` |
| `ui_ux` (implicit) | — | Not a separate registry kind; mapped via plan_debt + vertical stubs | `ui_ux_quality` goal |

---

## Studio-ui-ux plan todos

| Registry id | Todo | Status in tree | Action |
|-------------|------|----------------|--------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | studio-ux-16 | Shipped — see `docs/reports/studio-ui-ux/iterations/20260530T092400Z-studio-ux-16-palette-search-latency.md` | Close on snapshot refresh |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | studio-ux-17 | Pending | Handoff → `gui_ux_tester` |
| `gap-plan-pending-studio-ui-ux-studio-ux-21-wgpu-swapchain-gpu-runner` | studio-ux-21 | Patched to plan loop | studio-ui implement agent |
| `gap-plan-pending-studio-ui-ux-studio-ux-24-gpu-runner-deps` | studio-ux-24 | Patched to plan loop | studio-ui implement agent |

Backlog patches (stale apply file 2026-05-31): `benchmarks/data/latest/swarm-gap-actions.json` → studio-ux-21/24 patched to `2026-05-24-studio-ui-ux-plan-loop.md`.

---

## Cinematic / viz vertical stubs (UX competitor surface)

Patched competitor stubs with UX operator impact:

- `gap-vertical-stub-scientific-viz` → sim-md-research-backlog
- `gap-vertical-stub-cinematic-encode`, `cinematic-color-grade`, `cinematic-audio-sync`, `mmo-shard` → sim-md-research-backlog

**Routing:** research whitepapers via `game_engine_ux` / `ui_ux_quality` goals — **no new lic systemd loops**.

---

## Scripts attempted

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py   # OK → 63.9/D
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py                 # FAIL: PyYAML required
cd /workspace/lic && python3 scripts/swarm-gap-apply-actions.py          # not reached
```

**Control-plane fix merged locally:** `lic/scripts/swarm-gap-ingest.py:229` Path fallback (was SyntaxError).

---

## Swarm routing (no new registry ids)

| Next agent | Reason | north_star_fit |
|------------|--------|----------------|
| `gui_ux_tester` | `ui_ux_quality` goal; studio-ux-17 + viz stub honesty | ecosystem, web |
| `pr_merger` | lip#52 merge queue (briefing P0) | ecosystem |
| `ci_maintainer` | 14 repos missing CI | ecosystem |
| `gap_explorer` | 64 open gaps; ingest blocked until PyYAML | ecosystem, ai |
| `plan_verifier` | Refresh snapshot; close studio-ux-16 false-open | provable |

Research goal `swarm_coverage` remains on `swarm_observer` (cadence 6h) in `li-cursor-agents/config/research-goals.yaml`.

---

## Registry plan-debt row

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — **close on next ingest** after snapshot records `orch-r4` in `completed_ids` (this note is completion evidence).

---

## Human-only

- Studio GPU runner infra (wgpu swapchain deps) — org GPU runner policy; no auto-merge on `lic` master without review.
- Dashboard product UX changes in `li-studio` — human review via studio-ui PRs.

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `lic/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md`
- `data/runs/swarm_observer-1780841922772.md`
