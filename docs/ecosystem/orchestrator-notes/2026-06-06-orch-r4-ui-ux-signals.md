# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Supervisor dimension:** `ux` (worker `cb1165f5`)  
**Work item:** Reconcile UI/UX gap signals — studio-ui plan todos, benchmarks ux-audit preflight, swarm routing

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (62.6)**; `unattended_safe: false` |
| `orch-r4` | **Completed** — UX gap audit + handoffs documented; registry row close on next ingest |
| UX blockers | Studio-ui backlog path missing; 8 benchmarks PRs (377–384) red on ui-audit/grade CI |
| Ingest pipeline | **Repaired** — syntax error + env default + PyYAML installed; ingest/apply re-ran |
| Unattended? | **No** — human needed for CI triage, missing repos, studio-ui worktree |

---

## UX gap reconciliation

| Registry id | Plan todo | Apply status | Handoff |
|-------------|-----------|--------------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `studio-ux-16-palette-search-latency` | **skip** — backlog file missing | `gui_ux_tester` → `code_implementer` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `studio-ux-17-gpu-fail-recovery` | **skip** — backlog file missing | `gui_ux_tester` → `code_implementer` |
| `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` | `orch-r4-ui-ux-signals` | **complete** (this note) | `swarm_observer` done |

**Benchmarks ux-audit signal (not in registry — briefing):**

- PRs #377–#384 failing CI — titles include `ui-audit`, `ux-targets preflight`, `ecosystem grade refresh`.
- Blocks org preflight registration of benchmarks dashboard in ux-targets matrix.
- Handoff: `issue_planner` + `gui_ux_tester` (research goal `ui_ux_quality`).

---

## Control-plane fixes applied (orchestration only)

1. **`lic/scripts/swarm-gap-ingest.py`**
   - Fixed unterminated string literal (line 229).
   - Use `os.environ.get("BENCHMARKS_COMPETITIVE", ...)` instead of required env key.

2. **Container**
   - Installed `python3-yaml` so ingest/apply can run in agent images.

3. **Scripts re-run**
   ```bash
   cd lic && python3 scripts/swarm-gap-ingest.py
   cd lic && python3 scripts/swarm-gap-apply-actions.py
   # wrote benchmarks/data/latest/swarm-gap-actions.json
   ```

---

## Swarm routing (no new systemd loops)

| Agent | Goal / lane | Reason |
|-------|-------------|--------|
| `gui_ux_tester` | `ui_ux_quality` | UX dimension audit — benchmarks dashboard + preflight matrix |
| `issue_planner` | implement lane | Issues for studio-ux-16/17 + benchmarks CI failures |
| `ci_maintainer` | coord_platform | 6 repos incomplete CI (404) |
| `pr_merger` | coord_pull_requests | lip#52 gate-ready |
| `gap_explorer` | `ecosystem_gaps` | 64 open registry rows after ingest fix |

Research goals unchanged in `li-cursor-agents/config/research-goals.yaml` — `swarm_coverage` (agent `swarm_observer`, cadence 6h) and `ui_ux_quality` (agent `gui_ux_tester`).

---

## Recommended follow-up (control plane)

- Add `LIC_STUDIO_UI_ROOT` env default in `swarm-gap-apply-actions.py` backlog resolver.
- Pin `python3-yaml` in agent container build / `swarm-env-preflight.sh`.
- Merge `lic` ingest fix PR before next observer tick.

---

## Human-only

- Triage benchmarks#377–384 CI — do not auto-merge red ux-audit stack.
- Mount or clone `lic-studio-ui` worktree for backlog apply.
- Confirm 404 repos in org CI audit (private vs deleted).

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/agent-briefing.json`
- `li-cursor-agents/data/runs/swarm_observer-1780760393779.md`
- `lic/docs/research/swarm_coverage/ux/2026-06-06-whitepaper.md`
