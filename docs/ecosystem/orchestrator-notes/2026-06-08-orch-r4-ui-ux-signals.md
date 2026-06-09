# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-08  
**Agent:** `swarm_observer` (worker `7342f10f`)  
**Research goal:** `swarm_coverage` @ dimension `ux`  
**north_star_fit:** ecosystem, ai — swarm gap orchestration for UI/UX surfaces

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (60.9); `unattended_safe: false` |
| `orch-r4` | **In progress** — UX signals reconciled; registry rows need snapshot refresh to close |
| Studio UI/UX runner | **Stopped**; all `studio-ux-*` todos **done** in snapshot (2026-05-30) |
| UX audit surfaces | `lic-docs` **pass** (`ux-audit.json`, `ui-audit.json`); no `gui`/`tui` targets this cycle |
| Gap pipeline | **Blocked** — `swarm-gap-ingest.py` SyntaxError **fixed**; PyYAML still missing in container |
| Unattended? | **No** — ingest/apply cannot run; briefing P0 agents not yet dispatched |

---

## UX dimension audit

### Passing surfaces

| Target | Repo | Evidence | Rubric min |
|--------|------|----------|------------|
| `lic-docs` (static) | `lic` | `benchmarks/data/latest/ux-audit.json` | nav 0.85, task 0.80, cognitive 0.70 |

`ui-audit.json` (2026-05-31): 242 HTML files, 0 broken links, 0 axe violations.

### Stale registry drift (plan_debt → ui_ux)

Snapshot `studio-ui-ux` runner shows `studio-ux-04` … `studio-ux-08` as **done**, but registry still lists them **open**:

| Registry id | plan_todo_id | Snapshot status | Action |
|-------------|--------------|-----------------|--------|
| `gap-plan-pending-studio-ui-ux-studio-ux-04-particle-display` | `studio-ux-04-particle-display` | done | **close on ingest** after snapshot refresh |
| `gap-plan-pending-studio-ui-ux-studio-ux-05-studio-compose` | `studio-ux-05-studio-compose` | done | close |
| `gap-plan-pending-studio-ui-ux-studio-ux-06-agent-chrome` | `studio-ux-06-agent-chrome` | done | close |
| `gap-plan-pending-studio-ui-ux-studio-ux-07-capture-harness` | `studio-ux-07-capture-harness` | done | close |
| `gap-plan-pending-studio-ui-ux-studio-ux-08-bench-registry` | `studio-ux-08-bench-registry` | done | close |

Evidence: `lic/data/goal-directed-agents/snapshot.json` (runner `studio-ui-ux`, lines 557–629).

### Open UX work (not in registry as `ui_ux` kind)

- `studio-ux-16-palette-contrast` / `studio-ux-17-gpu-recovery` — next wave for `gui_ux_tester` via goal `ui_ux_quality`
- Dashboard: swarm health + gap-apply panel missing in `apps/org-supervisor-dashboard` (operator UX gap)
- `orch-r4-ui-ux-signals` plan todo still **pending** on `swarm-observer` runner — closes when this note lands + ingest runs

---

## Control-plane fix shipped

`lic/scripts/swarm-gap-ingest.py` line 229 SyntaxError remediated:

- Added `_verticals_toml_path()` with multi-candidate resolution (`BENCHMARKS_COMPETITIVE`, `benchmarks/workloads/competitive/verticals.toml`)
- Script now parses; blocked only on `PyYAML required`

---

## Swarm routing (no new systemd loops)

| Next agent | Reason | Handoff |
|------------|--------|---------|
| `gui_ux_tester` | Goal `ui_ux_quality` — palette + GPU recovery benches | `code_implementer`, `issue_planner` |
| `gap_explorer` | 64 open gaps; reconcile after ingest green | `swarm_coverage` north_star_fit |
| `pr_merger` | P0: lip#52 gate-ready | merge queue rank 1 |
| `ci_maintainer` | 12 repos missing CI | platform coordinator |
| `plan_verifier` | Refresh snapshot → close stale studio-ux gap rows | `orch-r4` completion |

---

## Registry plan-debt rows

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — **close on next ingest** after snapshot records `orch-r4` in `completed_ids` (this note is completion evidence).
- Five `gap-plan-pending-studio-ui-ux-*` rows — close when snapshot `generated_at` > 2026-06-08.

---

## Human-only

- Studio product UX changes (`li-studio`, `li-gui`) — no auto-merge without review.
- Merge lip#52 and lic gap-ingest fix PR via human or `pr_merger` after CI green.

---

## Evidence paths

- `benchmarks/data/latest/ux-audit.json`
- `benchmarks/data/latest/ui-audit.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/data/goal-directed-agents/snapshot.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `app/data/runs/swarm_observer-1780897154009.md`
