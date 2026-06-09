# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-04  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage@ux` (north_star_fit: ecosystem, ai)  
**Work item:** Wire UI/UX gap signals from registry → swarm goals; close phantom studio-ui plan_debt rows

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (67.3); `unattended_safe: false` |
| `orch-r4` | **Completed (evidence run)** — UX reconciliation documented; ingest syntax fixed |
| Operator UX | Empty CP disk cache + DB down → dashboard blind; gap registry shows stale studio-ui debt |
| Studio-ui truth | Plan loop **completed** todos 16–17, 21, 24; registry still **open** (snapshot lag) |
| Unattended? | **No** — PyYAML + CP persistence required before gap apply can run in Job |

---

## UI/UX gap taxonomy (`gap_kind: ui_ux` / studio-ui plan_debt)

Per swarm mandate, `ui_ux` gaps are discovered by `gui_ux_tester` / studio-ui loop and orchestrated via registry + research goals — **not** new lic systemd loops.

| Signal | Registry / plan | Live state | Reconcile |
|--------|-----------------|------------|-----------|
| Palette search latency | `studio-ux-16` | completed 2026-05-30 | **Close** registry row |
| GPU fail recovery | `studio-ux-17` | completed 2026-05-30 | **Close** registry row |
| wgpu swapchain GPU runner | `studio-ux-21` | completed 2026-05-31 | **Close** registry row |
| GPU runner deps | `studio-ux-24` | completed (state.json) | **Close** registry row |
| Ongoing UX audit | `ui_ux_quality` goal | enabled, agent `gui_ux_tester` | **Handoff** — cadence research lane |

Evidence:

- `lic/data/studio-ui-ux-plan-loop/state.json` — `completed_ids` includes 16, 17, 21, 24
- `lic/data/swarm-gap-registry/registry.yaml` — matching `gap-plan-pending-studio-ui-ux-*` rows still `status: open`
- `benchmarks/data/latest/swarm-gap-actions.json` — last apply 2026-05-31 (patches 21/24 to plan loop doc)

---

## Operator UX findings (swarm_coverage@ux lens)

1. **Invisible health:** org-research Jobs write runs to `/app/data/runs/` but grader reads `/workspace/li-cursor-agents/data/runs` → `runs_sampled: 0`, scorecard understates execution risk.
2. **Phantom debt:** open registry rows for completed studio-ui todos inflate `gap_pressure` and mis-route heap away from briefing P0 (`ci_maintainer`, `security_auditor`).
3. **Opaque prep failures:** ingest SyntaxError + missing PyYAML surface as silent skip unless operator reads Job logs — no row in dashboard interventions.

---

## Scripts status

```bash
cd lic
python3 scripts/swarm-gap-ingest.py    # blocked: PyYAML; syntax L229 fixed 2026-06-04
python3 scripts/swarm-gap-apply-actions.py  # blocked: PyYAML
```

**Fix applied (working tree):** `scripts/swarm-gap-ingest.py` — `BENCHMARKS_COMPETITIVE` default → `benchmarks/competitive/verticals.toml`.

**Infra follow-up:** bake `python3-yaml` in org-research image; set `LI_CURSOR_AGENTS_ROOT=/app`.

---

## Swarm routing (no new registry ids)

| Next agent | Reason |
|------------|--------|
| `gui_ux_tester` | `ui_ux_quality` goal — capture harness, palette/GPU gates, proactive sweeps |
| `plan_verifier` | Refresh goal-directed snapshot; drive registry close for completed studio-ui todos |
| `gap_explorer` | `gap_pressure` dimension < 80; vertical stub ingest after `verticals.toml` on main |
| `ci_maintainer` | Briefing P0 — 1 repo missing CI (operator-visible platform gap) |

Research lane: keep `swarm_coverage` on `swarm_observer` (priority 10, cadence 6h) in `li-cursor-agents/config/research-goals.yaml`.

---

## Registry plan-debt row

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — **close on next ingest** after snapshot records completion (this note + `data/runs/swarm_observer-1780548746697.md`).

---

## Human-only

- Studio GPU/wgpu product work stays in `lic` / `lic-studio-ui` PRs — no auto-merge.
- CWE catalog mapping (19 Top25 gaps) is security-governed.

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/data/studio-ui-ux-plan-loop/state.json`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `li-cursor-agents/data/runs/swarm_observer-1780548746697.md` (Job mount: `/app/data/runs/`)
