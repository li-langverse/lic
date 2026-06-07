# Orchestrator note — `orch-r4-ui-ux-signals` (ux dimension)

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Org research worker:** `d1873f1a` · dimension **`ux`**  
**Work item:** Surface studio-ui-ux / `gui_ux_tester` signals as `ui_ux` gaps; link studio backlog; close operator UX blind spots

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (65.3); `unattended_safe: false` |
| `orch-r4` | **In progress** — UX signals documented; registry row remains `plan_debt` until studio backlog mount |
| UX audit coverage | **Narrow** — `ux-audit.json` / `ui-audit.json` only score `lic-docs` static site |
| Operator UX gap | **High** — no dashboard panel for gap-apply status; control-plane IPC mirrors bootstrapped this run |
| Unattended? | **No** — PyYAML missing blocks live ingest/apply; briefing heap not executing |

Programmatic prep: **blocked** — `swarm-gap-ingest.py` syntax fixed (line 229); apply still requires `PyYAML` (not in org-research image).

Evidence:

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (regenerated 2026-06-07T17:56:46Z)
- `/workspace/benchmarks/data/latest/ux-audit.json`, `ui-audit.json`
- `/workspace/benchmarks/data/latest/studio-ui-ux-builder-digest.md`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml` → `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals`

---

## `ui_ux` gap taxonomy reconcile

| Signal source | Gap kind | Registry / backlog | Handoff |
|---------------|----------|-------------------|---------|
| `orch-r4-ui-ux-signals` plan todo | `plan_debt` | `swarm-observer-plan-backlog.md` (pending) | `swarm_observer` (this run) |
| Studio UX-01 wgpu viewport grid | `ui_ux` | `lic-studio-ui` plan loop (not mounted) | `studio_ui_ux_builder` via `gui_ux_tester` |
| Dashboard empty health/gap feed | `ui_ux` | li-cursor-agents dashboard | `issue_planner` + control-plane PR |
| `ux-audit` docs-only scope | `ui_ux` | `ui_ux_quality` research goal | `gui_ux_tester` |
| Swarm operator error opacity | `ui_ux` | org-research persist failures (historical) | control-plane circuit-breaker |

**No new registry ids.** Route via existing goals:

- `ui_ux_quality` → `gui_ux_tester` (cadence research lane)
- `game_engine_ux` vertical → studio backlog linkage when `lic-studio-ui` mount available

---

## UX dimension findings (worker `d1873f1a`)

### Operator / control-plane surfaces

1. **Empty dashboard health artifacts** — `data/control-plane/state.json` and `latest-report.json` were absent pre-run; bootstrapped manually. Operators cannot see gap-apply progress without reading raw JSON under `benchmarks/data/latest/`.
2. **Goal orientation UX** — Briefing recommends `pr_merger` → `ci_maintainer` → `security_auditor`; research lane runs `swarm_observer` meta-audits instead. Heap plan visible in briefing but not reflected in recent execution (expected for research slot, confusing for operators).
3. **Error message quality** — Prior org-research runs surfaced `agent_runs upsert: undefined`; current container has `LIC_ROOT=/workspace/lic` and `CURSOR_API_KEY` set (auth OK).

### Product UX signals (studio / docs)

| Surface | Status | Evidence | Severity |
|---------|--------|----------|----------|
| `lic-docs` static site | pass | `ux-audit.json` rubric ≥ 0.7 | low |
| `world-studio-demo` harness | partial | `studio-ui-ux-builder-digest.md` — native SDL gap | medium |
| Dashboard gap charts | 12 pending | `dashboard-gap-report.json` P1 chart_pending | medium |
| Org supervisor dashboard | no swarm health panel | observer recommendation from prior ux runs | high |

---

## Handoffs (cite north_star_fit: ecosystem, ai)

| To | Reason | PH / domain |
|----|--------|-------------|
| `gui_ux_tester` | Extend audit beyond `lic-docs`; probe dashboard + studio surfaces | PH-UX, easy pillar |
| `studio_ui_ux_builder` | UX-01 viewport grid; GPU recovery todos in studio loop | game_engine_ux |
| `issue_planner` | Dashboard swarm health + gap-apply panel issue | agentic_ai |
| `gap_explorer` | Ingest studio competitive gaps when `verticals.toml` readable | ecosystem |
| `pr_merger` | lip#52 gate-ready merge (operator queue clarity) | coord_pull_requests |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — retired; use async swarm control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Recommended control-plane fixes

| Path | Change |
|------|--------|
| `lic/scripts/swarm-gap-ingest.py:229` | **Fixed** — Path fallback syntax for `verticals.toml` |
| org-research Job image | Bake `python3-yaml` (or `PyYAML` wheel) for ingest/apply |
| `li-cursor-agents` worker env | Set `LI_CURSOR_AGENTS_ROOT=/app` so grader `runs_sampled>0` |
| `apps/org-supervisor-dashboard` | Panel: ecosystem grade + gap-apply rows from `swarm-gap-actions.json` |
| `config/goal-scaffolds/swarm_coverage.md` | UX dimension checklist (orch-r4 studio + dashboard) |

---

## Human-only blockers

- lip#52 merge on protected branch
- lis#40–#42 failing CI (registry/MCP/edge)
- GitHub API rate limit → `org_ci_audit` HTTP 403
- `lic-studio-ui` worktree not mounted → studio backlog patches skipped
- `research-findings` not mounted → whitepaper publish deferred

---

## Next orch todo

After PyYAML bake + studio mount: mark `orch-r4-ui-ux-signals` **completed** in `swarm-observer-plan-backlog.md` and close registry row `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals`.
