# Orchestrator note — orch-r4 UI/UX signals (worker 7a024cc2)

**Date:** 2026-06-07  
**Goal:** `swarm_coverage` · **Dimension:** `ux`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Registry row:** `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals`

## UX lens summary

Swarm orchestration UX degrades when operators cannot see gap-apply status, studio-ui backlog health, or briefing alignment. This pass reconciles `ui_ux` / `plan_debt` gaps without product code in `lic`.

## Evidence

| Signal | Path |
|--------|------|
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap apply output | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Ecosystem scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Goal-directed snapshot (stale) | `/workspace/lic/data/goal-directed-agents/snapshot.json` |
| Control-plane bootstrap | `/app/data/control-plane/latest-report.json` |
| Studio-ui runner stopped | snapshot `studio-ui-ux` `running: false` |

## Reconciliation (this cycle)

1. **Fixed** `swarm-gap-ingest.py:229` Path fallback syntax — ingest now runs with PyYAML.
2. **Re-ran** `swarm-gap-ingest.py` → registry 92 gaps; **apply** → `open_gaps: 62` (was 64).
3. **Studio-ui UX gaps** (`studio-ux-21-wgpu-swapchain-gpu-runner`, `studio-ux-24-gpu-runner-deps`): apply skipped — `/workspace/lic-studio-ui` not mounted. Route via `gui_ux_tester` + `ui_ux_quality` goal, not new systemd loops.
4. **orch-r4-ui-ux-signals**: remains open until snapshot refresh closes plan todo; this note satisfies UX audit deliverable for the research lane.

## Handoffs (swarm goals — no new agent ids)

| Target | Action |
|--------|--------|
| `gui_ux_tester` | `ui_ux_quality` goal — audit studio-ui GPU recovery, palette latency, dashboard swarm-health panel |
| `gap_explorer` | `ecosystem_gaps` — reconcile 30 `competitor_feature` rows after verticals ingest unblocked |
| `plan_verifier` | Refresh goal-directed snapshot; close stale `studio-ux-*` completed_ids vs plan_pending drift |
| `issue_planner` | `pkg-line-profiler` missing_package row |

## Do not

- Recommend `install-goal-plan-loop-systemd.sh` for studio-ui (migrated to agents control plane).
- Patch `lic-studio-ui` product code from this meta-agent pass.
