# Orchestrator note — `orch-r0-ingest-snapshot`

**Date:** 2026-05-25  
**Agent:** `swarm_observer`  
**Branch:** `cursor/swarm-observer-plan-loop`  
**Work item:** Run `swarm-gap-ingest.py`; reconcile registry with snapshot + audits; confirm `swarm-gap-apply-actions.py` dry-run and live apply.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 62.4; `unattended_safe: false`) |
| Goal-directed loops | **Healthy** — 8 runners, 0 stopped, 7 agents live |
| Gap registry | **48 open** after ingest (was 45); ingest added 3 snapshot rows |
| Unattended? | **No** — preflight failures, 40 failing PRs, 78% incomplete run rate |

Programmatic prep **confirmed**: ingest dry-run + live write; apply-actions dry-run + live write to `benchmarks/data/latest/swarm-gap-actions.json`. This iteration closed `orch-r0-ingest-snapshot` in registry and observer backlog.

---

## Gap counts by `gap_kind`

| `gap_kind` | Open (post-ingest) | Closed this cycle | Discoverer |
|------------|-------------------:|------------------:|------------|
| `missing_package` | 5 | 0 | `gap_explorer` |
| `plan_debt` | 42 | 1 (`orch-r0`) | `plan_verifier`, snapshot |
| `competitor_feature` | 0 | — | `gap_explorer` (orch-r2) |
| `ui_ux` | 0 | — | `gui_ux_tester` (orch-r4) |

**Ingest delta:** `plan_debt_snapshot: +3` (security-research runner todos + triple-prefixed httpd mirror rows). No new `missing_package` or competitor rows.

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py          # → registry.yaml (48 gaps)
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py   # → benchmarks/data/latest/swarm-gap-actions.json
SWARM_OBSERVER_REQUIRE_NOTE=docs/ecosystem/orchestrator-notes/2026-05-25-orch-r0-ingest-snapshot.md \
  ./scripts/swarm-observer-plan-gates.sh
```

---

## Backlog patches applied / deferred

### Applied (live)

| Target | Patches |
|--------|---------|
| `docs/ecosystem/ecosystem-package-backlog.md` | 5 × `pkg-*` → pending |
| `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` | 9 × httpd phase-2 / mirror todos |
| `docs/ecosystem/sim-algorithm-backlog.md` | 3 × sim P1/P2 todos |
| `docs/ecosystem/sim-md-research-backlog.md` | 3 × MD research todos |
| `docs/ecosystem/sim-chem-research-backlog.md` | 4 × chem research todos |
| `docs/ecosystem/security-research-backlog.md` | 4 × sec-r* todos (new mapping) |

### Deferred

| Reason | Count | Follow-up |
|--------|------:|-----------|
| Master-plan `plan_debt` (no runner backlog) | 8 | `plan_verifier` / `issue_planner` |
| `studio-ui-ux` plan file outside lic ROOT | 7 | orch-r4: use `lic-studio-ui/.../2026-05-24-studio-ui-ux-plan-loop.md` via `STUDIO_UI_UX_PLAN_PATH` |
| Swarm-observer meta todos (orchestration) | 4 | orch-r1–r4 on this loop |

**Systemd loops:** Do **not** add new lic plan loops. Existing loops (`httpd`, `sim`, `sim-md-research`, `sim-chem-research`, `security-research`, `swarm-observer`) are sufficient; route via `li-cursor-agents` research/implement goals per `docs/ecosystem/swarm-architecture.md`.

---

## Self-heal actions (control plane)

| Layer | Action |
|-------|--------|
| **This cycle** | Closed registry row `gap-plan-pending-swarm-observer-orch-r0-ingest-snapshot`; marked `orch-r0` completed in `swarm-observer-plan-backlog.md` |
| **apply-actions** | Added `security-research` backlog mapping; `studio-ui-ux` resolves via `STUDIO_UI_UX_PLAN_PATH` (default: sibling `lic-studio-ui` plan) |
| **orch-r1 (next)** | Dedupe httpd `gap-httpd-gap-*` triple-prefix rows; align ingest slug with snapshot `plan_todo_id` |
| **Observer (li-cursor-agents)** | Treat 80× `running` runs as stuck-SDK sweep candidate; incomplete rate 78% |
| **Briefing** | 2 preflight failures — refresh `plan_verifier` audit before unattended mode |

No product code in lic. No new agent registry IDs.

---

## Recommended control-plane fixes (file paths)

| Priority | Path | Change |
|----------|------|--------|
| P1 | `lic/scripts/swarm-gap-ingest.py` | Normalize `plan_todo_id` before gap id slug (avoid `gap-httpd-gap-httpd-gap-*`) |
| P1 | `lic/scripts/swarm-gap-apply-actions.py` | Done: `security-research`, `STUDIO_UI_UX_PLAN_PATH` |
| P2 | `li-cursor-agents/prompts/swarm-observer.md` | Require orch note path + gap_kind table in deliverable |
| P2 | `li-cursor-agents/src/observer/` | Stuck-run detector: `running` > N hours → retry budget |
| P3 | `benchmarks/scripts/ecosystem-quality-grade.py` | Refresh after registry close (grade still cites 45 gaps) |

---

## Human-only blockers

- **40 open PRs with failing CI** — merge/rebase requires human review
- **32 repos missing CI on main** — org policy / `ci_maintainer`
- **CURSOR_API_KEY** — if absent, programmatic SDK heal cannot run (not verified this cycle)
- **Governance PRs** — provability gates must not be auto-disabled

---

## Agent deliverable checklist

- [x] `swarm-gap-ingest.py` ran; registry reconciled with snapshot
- [x] `swarm-gap-apply-actions.py` dry-run + live apply confirmed
- [x] Gap counts by kind documented
- [x] Registry updated (`orch-r0` closed)
- [x] Orchestrator note written (this file)
- [x] `swarm-observer-plan-gates.sh` (with note env)
- [ ] PR opened on `cursor/swarm-observer-plan-loop` (push after commit)

**Report:** `lic/data/runs/swarm_observer-orch-r0-ingest-snapshot.md`
