# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-04  
**Goal:** `swarm_coverage@ux` · **Worker:** `63f5d95b`  
**north_star_fit:** ecosystem, ai — proof-before-perf; easy operator surfaces for swarm health

## Context

Plan todo `orch-r4-ui-ux-signals` asks the swarm observer to surface studio-ui-ux / `gui_ux_tester` signals as `ui_ux` gaps and link studio backlog items. Registry row `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` remains **open**; `swarm-gap-apply-actions.py` defers it (no swarm-observer runner backlog file).

Evidence:

- `/workspace/lic/data/goal-directed-agents/snapshot.json` — runner `studio-ui-ux`, `active_todo_id: studio-ux-16-palette-search-latency`, supervisor off
- `/workspace/benchmarks/data/latest/ux-audit.json`, `ui-audit.json` — `lic-docs` passes
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json` — studio-ux-16/17 apply **skipped** (missing `lic-studio-ui` plan loop mount)

## UX signals ingested this pass

| Signal | Source | Severity | Action |
|--------|--------|----------|--------|
| Operator cannot see gap apply | No dashboard panel | medium | `li-cursor-agents` dashboard issue |
| CP health opaque | MCP `ECONNREFUSED`, no disk mirrors | critical | Persist `latest-report.json` + fail-fast |
| Studio palette latency todo active | snapshot `studio-ux-16` | high | Handoff `gui_ux_tester` |
| GPU fail recovery todo pending | snapshot `studio-ux-17` | high | Handoff `gui_ux_tester` + lic#575 |
| Docs UX baseline green | ux/ui audit JSON | info | Expand coverage to TUI/CLI |
| `ui_ux` gap_kind count = 0 | registry taxonomy | medium | `gap_explorer` promote audit friction rows |

## Handoff routes (no new agent ids)

| Target | Work |
|--------|------|
| `gui_ux_tester` | Run `ui_ux_quality` goal; benchmark studio-ux-16/17 gates; file `ui_ux` registry rows from harness friction |
| `plan_verifier` | Refresh snapshot after studio wave-4; close duplicate plan_debt rows |
| `issue_planner` | lic#575 studio master-plan; ensure `lic-studio-ui` mounted on org-research Jobs |
| `gap_explorer` | Map competitor studio stubs + audit gaps → registry `ui_ux` kind |
| `swarm_observer` | Next cadence: verify gap apply patches studio backlog once mount fixed |

## Do not

- Recommend `install-goal-plan-loop-systemd.sh` — retired; use agents control plane (`docs/ecosystem/swarm-architecture.md`).
- Invent new registry agent ids.
- Auto-merge governance or provability PRs.

## Evidence paths

- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml` → `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals`
- `/app/data/runs/swarm_observer-1780541321065.md`
