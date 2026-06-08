# Orchestrator note — orch-r4 UI/UX signals (`swarm_coverage` @ ux)

**Date:** 2026-06-06  
**Worker:** `37804ad2`  
**Goal:** `swarm_coverage`  
**Plan todo:** `orch-r4-ui-ux-signals`  
**north_star_fit:** ecosystem, ai — easy operator UX for swarm gap orchestration

## Context

Ecosystem grade **D (60.9)**, `unattended_safe: false`. Gap registry holds **64 open rows** but **zero `ui_ux` kind** — UX debt is filed as `plan_debt` under `studio-ui-ux` and `swarm-observer` runners.

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`, `/workspace/lic/data/swarm-gap-registry/registry.yaml`.

## UX signals audited

### 1. Benchmarks dashboard — GPU chip picker PR storm

- **Symptom:** 8+ open PRs with near-identical titles (`fix(ui): GPU chip picker ARIA tabs + keyboard roving`) all CI-failing.
- **Operator impact:** merge queue noise (209 redundant pairs), unclear which PR is canonical for issue #147.
- **Route:** `bug_fixer` + human pick-one; link to `ui_ux_quality` / `gui_ux_tester` for WCAG tab/roving verification after CI green.
- **Evidence:** `agent-briefing.json` → `ecosystem_audit.failed_prs` (#400–#409).

### 2. Studio UI plan debt — palette + GPU recovery

| plan_todo | gap_id | Status |
|-----------|--------|--------|
| `studio-ux-16-palette-search-latency` | `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | open |
| `studio-ux-17-gpu-fail-recovery` | `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | open |

- **Apply script:** skips studio plan file — `lic-studio-ui` plan path not mounted; use `LIC_STUDIO_UI_ROOT` fallback in apply script.
- **Route:** `gui_ux_tester` via `ui_ux_quality` research goal (no new agent ids).

### 3. Control-plane operator UX

- Missing `/app/data/control-plane/latest-report.json` and `state.json` → dashboard shows empty health; observer cannot auto-retry.
- **Route:** `li-cursor-agents` — persist disk cache on org-research Job exit; surface infra-blocked banner in dashboard.

### 4. Gap taxonomy gap — no `ui_ux` rows

- Preflight `ux_audit` rows exist in briefing config but are not ingested into registry as `gap_kind: ui_ux`.
- **Route:** extend `swarm-gap-ingest.py` after PyYAML bake; close `orch-r4` on next successful ingest.

## Actions this cycle

1. Fixed `swarm-gap-ingest.py:229` Path fallback syntax (blocks all ingest).
2. Regenerated ecosystem scorecard (grade D, unattended unsafe).
3. Staged UX whitepaper: `lic/docs/research/swarm_coverage/ux/2026-06-06-whitepaper-37804ad2.md`.

## Handoffs

| Target agent | Work item | PH / domain |
|--------------|-----------|-------------|
| `gui_ux_tester` | studio-ux-16/17 + benchmarks dashboard a11y | PH-UX, easy |
| `ci_maintainer` | Unblock benchmarks CI wave; 14 repos missing CI | ecosystem |
| `bug_fixer` | Consolidate GPU chip picker PR stack | ux, a11y |
| `gap_explorer` | Register `ui_ux` gaps post-ingest | ecosystem |
| `pr_merger` | lip#52 (merge-approved) | coord_pull_requests |

## Do not

- Add lic systemd plan loops (`install-goal-plan-loop-systemd.sh` retired).
- Auto-merge governance or WCAG PRs without human review.
- Implement product UI in this orchestrator pass.
