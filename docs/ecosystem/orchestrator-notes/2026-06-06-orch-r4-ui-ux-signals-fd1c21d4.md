# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Worker:** `fd1c21d4`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `ux`  
**Work item:** Reconcile UX signals across benchmarks dashboard, studio-ui-ux plan loop, and static audits; route handoffs

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (60.9); `unattended_safe: false` |
| `orch-r4` | **Completed** — UX signal map + handoffs documented |
| Primary UX blocker | 8 duplicate **benchmarks** GPU chip picker PRs (#400–409), all CI red |
| Studio UI | 11 `plan_debt` registry rows; runner stopped in stale snapshot |
| Static audits | `lic-docs` pass (`ux-audit.json`, `ui-audit.json`) |
| Unattended? | **No** — gap ingest blocked; failed PR CI; missing CP state |

Programmatic prep: **blocked** — `swarm-gap-ingest.py` SyntaxError @ line 229; `swarm-gap-apply-actions.py` requires PyYAML (not installed).

---

## UX signal reconciliation

### 1. Benchmarks dashboard — GPU chip picker (P0)

| Signal | Detail |
|--------|--------|
| Failed PRs | #400, #401, #402, #404, #405, #406, #407, #409 (8 in briefing sample) |
| Symptom | Duplicate `fix(ui|dashboard): GPU chip picker ARIA tabs + keyboard roving (#147)` |
| UX impact | Operators cannot land any accessibility fix; merge queue noise (193 redundant pairs org-wide) |
| Action | Consolidate to **one** canonical PR; close duplicates; handoff `gui_ux_tester` for axe/tabpanel verification |

Evidence: `/workspace/benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.failed_prs`

### 2. Studio UI/UX plan loop (P1)

| Registry prefix | Count | Sample todos |
|-----------------|-------|--------------|
| `gap-plan-pending-studio-ui-ux-*` | 11 | `studio-ux-04-particle-display`, `studio-ux-06-agent-chrome`, `studio-ux-21-wgpu-swapchain-gpu-runner`, `studio-ux-24-gpu-runner-deps` |

Patches already applied @ 2026-05-31 to `2026-05-24-studio-ui-ux-plan-loop.md` (2 rows). Remaining rows await snapshot refresh + `gui_ux_tester` cadence via `ui_ux_quality` goal.

Evidence: `/workspace/lic/data/swarm-gap-registry/registry.yaml`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`

### 3. Static doc UX (healthy)

| Audit | Target | Result |
|-------|--------|--------|
| `ux-audit.json` | `lic-docs` | pass — nav_clarity 0.85, rubric_min 0.7 met |
| `ui-audit.json` | `lic-docs` | pass — 0 axe violations, 242 html files |

Gap: live **org-supervisor-dashboard** and **benchmarks** interactive surfaces not in audit scope.

### 4. Gap taxonomy gap

Registry has **0** rows with `gap_kind: ui_ux`. Studio and dashboard friction is classified only as `plan_debt`. Recommend ingest reclass for operator-facing surfaces.

---

## Handoffs (no new systemd loops)

| Agent | Goal / lane | Reason |
|-------|-------------|--------|
| `gui_ux_tester` | `ui_ux_quality` | Benchmarks GPU picker consolidation + studio-ux plan todos |
| `studio_ui_ux_builder` | `implement-goals.yaml` | wgpu viewport, capture harness (lic worktree) |
| `pr_alignment` | coord_pull_requests | Close redundant benchmarks PR stack |
| `gap_explorer` | `ecosystem_gaps` | After ingest green — competitor_feature backlog |
| `swarm_observer` | `swarm_coverage` | Next dimension rotation per cadence |

Research routing unchanged in `li-cursor-agents/config/research-goals.yaml` — `swarm_coverage` @ priority 10, cadence 6h.

---

## Registry plan-debt row

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — **close on next ingest** after snapshot records `orch-r4-ui-ux-signals` in `completed_ids` (this note is completion evidence).

Prior row `orch-r3-missing-package-sweep` still open in registry — close when snapshot catches up from 2026-05-30 stale state.

---

## Scripts attempted

```bash
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py
# SyntaxError line 229 — not executed

python3 scripts/swarm-gap-apply-actions.py
# PyYAML required — not executed
```

Fallback: read-only reconcile from frozen `swarm-gap-actions.json` @ 2026-05-31T01:45:58Z.

---

## Human-only

- Merge consolidated benchmarks UX PR after human review
- lip#52 (`actions/deploy-pages` bump) — merge-approved, protected branch
- Studio native capture (`libsdl2`) — environment-dependent
- trusted.lean / governance — never auto-merge

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/ux-audit.json`
- `/workspace/benchmarks/data/latest/ui-audit.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780784700908.md`
- `/workspace/lic/docs/research/swarm_coverage/ux/2026-06-06-whitepaper-fd1c21d4.md`
