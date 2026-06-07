# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `f5dfdd50`  
**Research goal:** `swarm_coverage`  
**Dimension:** `ux`  
**north_star_fit:** ecosystem, ai — easy UX for agent operators and benchmark consumers

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 60.9; `unattended_safe: false`) |
| `orch-r4` | **Open** — UX signal reconciliation incomplete |
| UX gap pressure | **2** open `studio-ui-ux` plan todos + **8+** failed benchmarks ARIA PRs (#400–409) |
| Gap ingest | **Blocked** — `swarm-gap-ingest.py:229` SyntaxError (fixed locally); PyYAML missing in worker |
| Unattended? | **No** — GPU picker PR stack failing CI; gap apply cannot refresh studio backlogs |

---

## UX dimension audit (evidence)

### Benchmarks dashboard — GPU chip picker ARIA cluster

| Symptom | Evidence | Severity |
|---------|----------|----------|
| 8+ duplicate PRs, all CI fail | `agent-briefing.json` → `ecosystem_audit.failed_prs` (#400–409) | **high** |
| WCAG tabs + keyboard roving (#147) | Same titles across `fix(ui)` / `fix(dashboard)` branches | **high** |
| Swarm cannot auto-merge UX fixes | All `ready: false`, `ci: fail` | **medium** |

**Root cause class:** repo conflict + redundant PR stack, not SDK auth. Human must pick one PR or rebase stack before `gui_ux_tester` can close loop.

### Studio-ui-ux plan debt (registry)

| Gap id | Plan todo | Status | Handoff |
|--------|-----------|--------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `studio-ux-16-palette-search-latency` | open | `swarm_observer` → `gui_ux_tester` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `studio-ux-17-gpu-fail-recovery` | open | `swarm_observer` → `gui_ux_tester` |

**Apply script:** deferred — `lic-studio-ui` worktree not mounted; backlog path skipped in prior runs.

### Swarm observer orch todos

| Todo | Status | Action this pass |
|------|--------|------------------|
| `orch-r4-ui-ux-signals` | open | Document UX audit; handoff `gui_ux_tester` on `ui_ux_quality` |
| `orch-r3-missing-package-sweep` | open | Out of UX scope — defer to `issue_planner` |

---

## Reconciliation actions (Mode B)

1. **Do not** spawn new lic systemd loops — route via `gui_ux_tester` + research lane (`ui_ux_quality` goal).
2. **Handoff** `gui_ux_tester`: consolidate benchmarks GPU picker PR stack; axe/Playwright on org-supervisor-dashboard when CP state persists.
3. **Handoff** `gap_explorer`: after ingest unblocked, re-ingest `verticals.toml` stubs for `scientific_viz` UX honesty rows.
4. **Close `orch-r4`** when: (a) ingest+apply green, (b) studio-ux-16/17 patched or completed in snapshot, (c) one GPU picker PR merged.

---

## Handoffs (cite north_star_fit)

| Target agent | Reason | PH / domain |
|--------------|--------|-------------|
| `gui_ux_tester` | GPU picker ARIA + studio-ux-16/17 | easy, ecosystem |
| `pr_merger` | lip#52 deps (unblocks merge lane) | ecosystem |
| `ci_maintainer` | 14 repos missing CI | secure, ecosystem |
| `gap_explorer` | 64 open registry rows post-ingest | ai, ecosystem |

---

## Evidence paths

- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- Gap actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Briefing failed PRs: `/workspace/benchmarks/data/latest/agent-briefing.json`
- Run report: `/app/data/runs/swarm_observer-1780808107222.md`
