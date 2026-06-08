# Orchestrator note — orch-r4 UI/UX signals

**Date:** 2026-06-07  
**Worker:** `0c3ff7f3`  
**Goal:** `swarm_coverage` @ `ux`  
**north_star_fit:** ecosystem, ai — easy pillar (operator UX + studio SOTA)

## Summary

UX-dimension audit reconciles **studio-ui-ux plan progress** (local plan loop shows todos done) against **stale goal-directed snapshot** (2026-05-30) and **swarm-gap registry** rows still marked `open`. Primary UX blockers are orchestration, not product code.

## UX gap signals surfaced

| Signal | Registry / plan id | Status | Handoff |
|--------|-------------------|--------|---------|
| Command palette latency | `studio-ux-16-palette-search-latency` | done in plan loop; open in snapshot | `gui_ux_tester` |
| GPU fail recovery strip | `studio-ux-17-gpu-fail-recovery` | done in plan loop; open in snapshot | `gui_ux_tester` |
| wgpu swapchain GPU runner | `studio-ux-21-wgpu-swapchain-gpu-runner` | patched backlog; CI blocked | `code_implementer` via `ui_ux_quality` |
| GPU runner deps matrix | `studio-ux-24-gpu-runner-deps` | patched backlog | `ci_maintainer` |
| Benchmarks dashboard ARIA tabs | benchmarks#404–409 (issue #147) | 5+ failing CI PRs | `gui_ux_tester` + human consolidate |
| Swarm observer UX orch | `orch-r4-ui-ux-signals` | **this run** | `swarm_observer` |

## Registry reconciliation (no new loops)

1. After PyYAML unblock: run `swarm-gap-ingest.py` → refresh snapshot-derived `plan_debt` rows for studio-ui-ux.
2. Close `gap-plan-pending-studio-ui-ux-studio-ux-16-*` and `*-17-*` when snapshot reflects plan-loop `done` status.
3. Route live UX work through existing goals:
   - `ui_ux_quality` → `gui_ux_tester` (cadence 48h, priority 5)
   - `game_engine_ux` vertical for studio shell journeys
4. Do **not** spawn new lic systemd plan loops; retired per `docs/ecosystem/swarm-architecture.md`.

## Benchmarks dashboard UX (operator-facing)

Failed PR stack on GPU chip picker (`benchmarks` #404–409) blocks merge of ARIA tablist + keyboard roving fix (#147). Consolidate to one green PR before further UX agent runs.

Evidence: `agent-briefing.json` → `ecosystem_audit.failed_prs`

## Next handoffs

| Agent | Reason |
|-------|--------|
| `gui_ux_tester` | `ui_ux_quality` goal; axe/keyboard on benchmarks dashboard + studio shell |
| `ci_maintainer` | 13 repos missing CI; GPU runner deps for studio-ux-24 |
| `gap_explorer` | Re-ingest after PyYAML; close stale studio-ui registry rows |
| `pr_merger` | lip#52 merge-approved (unblocks deploy-pages UX for docs sites) |

## Evidence paths

- `/workspace/lic/data/swarm-gap-registry/registry.yaml` — `orch-r4`, studio-ux rows
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json` — studio backlog patches
- `/workspace/lic/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` — todos done vs snapshot drift
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` — grade D, unattended_safe=false
- `/workspace/benchmarks/data/latest/agent-briefing.json` — failed GPU picker PRs
