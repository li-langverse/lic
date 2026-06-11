# Orchestrator note — UX gap orchestration (`4afdfbd4`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `ux`  
**Worker:** `4afdfbd4`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (conditional)** — grade **C** (76.1); `unattended_safe: true` |
| Gap prep | **Blocked** — PyYAML missing; last apply @ `00:05:46Z` |
| Open gaps | **62** (studio UX items misclassified as open `plan_debt`) |
| UX audit posture | **Docs-only** preflight; five GUI targets not in routine briefing |
| CP artifacts | **Missing** — no `state.json` / `latest-report.json` |
| Unattended? | **Conditional** — agents run; operators lack honest health + UX audit pane |

---

## New finding: registry vs loop-state drift

`lic/data/studio-ui-ux-plan-loop/state.json` lists **`studio-ux-16-palette-search-latency`** and **`studio-ux-17-gpu-fail-recovery`** in `completed_ids`, but `swarm-gap-registry/registry.yaml` still has open rows and `swarm-gap-actions.json` shows `skip missing backlog`.

**Operator UX impact:** dashboard gap pressure overstates studio plan debt; erodes trust in registry as source of truth.

**Fix on next ingest:** `swarm-gap-ingest.py` should read studio loop `state.json` and close matching `gap-plan-pending-studio-ui-ux-*` rows.

---

## UX reconciliation (easy pillar — operator surfaces)

### Operator blind spots

1. No CP disk mirrors — retry budgets and `swarm_degraded` opaque across Job restarts.
2. Gap pipeline frozen — PyYAML missing; 62 gaps last patched @ `00:05:46Z`.
3. Preflight UX audits — `ux-audit.json` only exercises `lic-docs` (2026-05-30).
4. Briefing heap drift — scorecard recommends four agents; heap dispatches two.

### Studio / GUI gap routing

| Item | Status | Handoff |
|------|--------|---------|
| `orch-r4-ui-ux-signals` | open, apply deferred | Complete via `ui_ux_quality` → `gui_ux_tester` |
| `studio-ux-16`, `studio-ux-17` | **completed in loop state; open in registry** | Close on ingest; no new systemd loop |
| `gap-ux-audit-agents-dashboard` | skip in last sweep | `gui_ux_tester` + dev server ([#38](https://github.com/li-langverse/li-cursor-agents/issues/38)) |

Do **not** spawn new `studio-ui-ux` systemd loops — use research lane per [swarm-architecture.md](../swarm-architecture.md).

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

**Blocked:** `PyYAML required` — bake `python3-yaml` into org-research worker image.

---

## Handoffs

| To | Reason | north_star_fit |
|----|--------|----------------|
| `gui_ux_tester` | `orch-r4-ui-ux-signals`; five-target GUI sweep | ecosystem, easy |
| `gap_explorer` | 62 open gaps; post-PyYAML re-ingest + close stale studio rows | ecosystem, ai |
| `plan_verifier` | 31 plan_debt rows; snapshot refresh | provable |
| `issue_planner` | `li-line-profiler` missing package seed | ecosystem |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/studio-ui-ux-plan-loop/state.json`
- `/workspace/benchmarks/data/latest/ux-audit.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/app/data/runs/swarm_observer-1781166982235.md`
- `/workspace/lic/docs/research/swarm_coverage/ux/2026-06-11-whitepaper-4afdfbd4.md`
