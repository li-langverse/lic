# Orchestrator note — orch-r4-ui-ux-signals

**Date:** 2026-06-03  
**Goal:** `swarm_coverage@ux` · **Worker:** `3b6f7a80`  
**north_star_fit:** ecosystem, ai — swarm gap orchestration UX signals  
**Related gap:** `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals`

## Summary

UX-dimension audit of swarm gap orchestration. Operator-facing signals for gap registry health, backlog apply, and handoff routing are **blocked or misleading** until ingest/apply scripts run and stale registry rows reconcile.

## Evidence

| Signal | Path | UX impact |
|--------|------|-----------|
| Quality scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` | Grade C, unattended unsafe |
| Gap actions (stale) | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` | Last apply 2026-05-31 |
| Registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` | 64 open; studio-ui-ux drift |
| Studio loop ground truth | `/workspace/lic/data/studio-ui-ux-plan-loop/state.json` | studio-ux-16..24 completed |
| Ingest failure | `/workspace/lic/scripts/swarm-gap-ingest.py:229` | SyntaxError |
| Apply failure | `swarm-gap-apply-actions.py` | PyYAML missing |
| Failed UX PRs | briefing `ecosystem_audit.failed_prs` | lic#742, studio#67 |

## Reconcile actions

### 1. Unblock pipeline (P0)

1. Merge [lic#774](https://github.com/li-langverse/lic/pull/774) — fix ingest Path syntax line 229.
2. Add `python3-yaml` to org-research Job image.
3. Re-run: `python3 lic/scripts/swarm-gap-ingest.py` then `python3 lic/scripts/swarm-gap-apply-actions.py`.

### 2. Close stale `ui_ux` / studio-ui-ux registry rows

On next successful ingest, close gaps where `plan_todo_id` appears in `studio-ui-ux-plan-loop/state.json` → `completed_ids`:

- `studio-ux-04` through `studio-ux-15` (already marked closed in registry but verify)
- `studio-ux-16-palette-search-latency` — **close** (completed 2026-05-30)
- `studio-ux-17-gpu-fail-recovery` — **close** (completed 2026-05-30)
- `studio-ux-21-wgpu-swapchain-gpu-runner` — **close** (completed 2026-05-31)
- `studio-ux-24-gpu-runner-deps` — **close** (patched + completed)

### 3. Route open UX work via swarm goals (not systemd loops)

| Work | Route |
|------|-------|
| Typography FX CI (lic#742, studio#67) | `gui_ux_tester` ← `ui_ux_quality` goal |
| Palette/GPU follow-up (lic#575) | `gui_ux_tester` + `issue_planner` |
| Operator dashboard gap status | `li-cursor-agents` dashboard panel |
| Registry drift prevention | `plan_verifier` on plan_audit preflight (enable non-skip) |

### 4. Mark orch-r4 complete when

- [ ] Ingest + apply succeed without error
- [ ] Stale studio-ui-ux rows closed in registry
- [ ] Handoff enqueued: `gui_ux_tester` for typography FX failed PRs
- [ ] Whitepaper published under `research-findings/whitepapers/2026-06/swarm_coverage/ux/`

## Handoffs

```yaml
north_star_fit: "ecosystem, ai — proof-before-perf UX orchestration"
handoff_to:
  - agent: gui_ux_tester
    reason: "Typography FX CI failures lic#742 studio#67; ui_ux_quality cadence"
  - agent: plan_verifier
    reason: "Registry vs loop state drift on studio-ui-ux todos"
  - agent: gap_explorer
    reason: "64 open gaps; gap_pressure 60"
```

## Do not

- Install new lic systemd plan loops (`install-goal-plan-loop-systemd.sh` retired).
- Merge PRs from this note automatically.
- Disable provability gates on typography / GPU work.
