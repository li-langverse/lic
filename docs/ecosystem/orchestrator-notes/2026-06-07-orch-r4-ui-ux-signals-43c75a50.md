# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `43c75a50`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `ux`  
**Work item:** Close UX-signal gap orchestration — dashboard operator UX, studio-ui backlog, registry reconcile

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (65.8); `unattended_safe: false` |
| `orch-r4-ui-ux-signals` | **In progress** — UX audit complete; registry row remains open until snapshot refresh |
| UX lens | Operator sees empty health mirrors, opaque gap-apply status, studio-ui UX debt unlinked |
| Gap ingest | **Blocked** — `swarm-gap-ingest.py:229` syntax **remediated**; PyYAML still missing in worker image |
| Unattended? | **No** — briefing P0 agents (`pr_merger`, `ci_maintainer`, `security_auditor`) not executing |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`, `/app/data/control-plane/latest-report.json`.

---

## UX dimension findings

### Operator / control-plane UX

| Symptom | Evidence | Severity |
|---------|----------|----------|
| No persisted `state.json` / `latest-report.json` before this pass | `/app/data/control-plane/` (bootstrapped 2026-06-07T23:37Z) | high |
| `runs_sampled=0` in scorecard — dashboard run history empty | `ecosystem-quality-report.json` → `inputs.runs_dir` | high |
| Gap apply pipeline invisible to operators | `swarm-gap-actions.json` stale @ 2026-05-31; no dashboard panel | medium |
| Preflight failures opaque | `org_ci_audit` GH 403; `org_agent_kit_audit` missing mount | medium |

### Studio / product UX gaps (`ui_ux` taxonomy via `plan_debt`)

| Registry id | Plan todo | Apply patch | Handoff |
|-------------|-----------|-------------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `studio-ux-16-palette-search-latency` | deferred (no lic-studio-ui mount) | `gui_ux_tester` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `studio-ux-17-gpu-fail-recovery` | deferred | `gui_ux_tester` |
| `gap-plan-pending-studio-ui-ux-studio-ux-21-wgpu-swapchain-gpu-runner` | `studio-ux-21-wgpu-swapchain-gpu-runner` | patched → `2026-05-24-studio-ui-ux-plan-loop.md` | `gui_ux_tester` |
| `gap-plan-pending-studio-ui-ux-studio-ux-24-gpu-runner-deps` | `studio-ux-24-gpu-runner-deps` | patched → plan loop md | `gui_ux_tester` |

Route via `ui_ux_quality` goal + `gui_ux_tester` — **not** new lic systemd loops (`docs/ecosystem/swarm-architecture.md`).

---

## Gap reconcile actions (this pass)

1. **Remediated** `lic/scripts/swarm-gap-ingest.py:229` Path/verticals.toml fallback syntax (recurring SyntaxError).
2. **Bootstrapped** `/app/data/control-plane/state.json` + `latest-report.json` for dashboard IPC.
3. **Regenerated** `ecosystem-quality-report.json` (65.8 / D / unattended_safe=false).
4. **Deferred live ingest/apply** — PyYAML not available (`pip`, `apt`, `venv` all blocked in container).

---

## Handoff routes (north_star_fit: ecosystem, ai)

| Target agent | Gap kind | Reason |
|--------------|----------|--------|
| `gui_ux_tester` | `ui_ux` / studio plan_debt | UX-16 palette latency, UX-17 GPU recovery |
| `gap_explorer` | `competitor_feature` | 30 open competitor stubs; `verticals.toml` ingest blocked until yaml bake |
| `plan_verifier` | `plan_debt` | Refresh goal-directed snapshot (2026-05-30); close `orch-r3`/`orch-r4` rows |
| `ci_maintainer` | briefing P0 | 12 repos missing CI |
| `pr_merger` | briefing P0 | lip#52 gate-ready merge |
| `issue_planner` | `missing_package` | 3 package gaps → `ecosystem-package-backlog.md` |

---

## Human-only blockers

- lip#52 merge (protected branch)
- lic#1152, lic#1156, lis#40–42 failing CI
- GitHub API rate limit (`org_ci_audit` HTTP 403)
- Bake `python3-yaml` in org-research worker image (ephemeral installs fail)
- `trusted.lean` / provability gates — never auto-merge

---

## Close criteria for `orch-r4-ui-ux-signals`

- [ ] Dashboard exposes swarm health + gap-apply panel (`li-cursor-agents`)
- [ ] `gui_ux_tester` dispatched for studio-ux-16/17
- [ ] Live gap ingest/apply succeeds post-PyYAML bake
- [ ] Goal-directed snapshot refreshed; registry row marked closed
