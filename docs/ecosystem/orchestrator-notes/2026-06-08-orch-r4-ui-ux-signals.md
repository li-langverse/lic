# Orchestrator note — orch-r4 UI/UX signals (swarm_coverage@ux)

**Date:** 2026-06-08  
**Worker:** `0e217961`  
**Goal:** `swarm_coverage` / dimension `ux`  
**north_star_fit:** ecosystem, ai — swarm gap orchestration for operator UX surfaces  
**Registry row:** `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals`

## Summary

UX-dimension observer pass reconciled **ui_ux** / **plan_debt** signals against the swarm gap registry. The programmatic gap pipeline remains **blocked** on `PyYAML` in the org-research worker image; ingest syntax on `main` was repaired locally (line 229 Path fallback). Live re-ingest/apply deferred until image bake.

## UX gap taxonomy (this cycle)

| `gap_kind` | Open rows (registry) | Primary discoverer | Orchestrator action |
|------------|---------------------|--------------------|---------------------|
| `plan_debt` | `orch-r4-ui-ux-signals`, `orch-r3-missing-package-sweep` | `plan_verifier` | Document UX signals; handoff `gui_ux_tester` |
| `ui_ux` (studio-ui) | studio-ux-04…18 (snapshot drift) | `gui_ux_tester` / studio-ui loop | Link plan todos; close rows after snapshot refresh |
| `competitor_feature` | 30 stubs | `gap_explorer` | Not UX-critical — research lane |
| `missing_package` | 3 (std.plot, std.summary, line_profiler) | `gap_explorer` | `issue_planner` via ecosystem-package-backlog |

## Studio-ui snapshot drift

Registry rows for `studio-ui-ux` show `plan_pending` **and** `completed_ids includes …` in evidence — stale goal-directed snapshot (2026-05-30). Priority UX todos for swarm handoff:

- **studio-ux-16** — palette search latency (`packages/li-ui/bench/palette_latency.toml`)
- **studio-ux-17** — GPU fail recovery (`packages/li-studio/bench/gpu_fail_recovery.toml`)
- **UX-01** — wgpu viewport grid (open competitor/studio backlog)

**Handoff:** `gui_ux_tester` ← `ui_ux_quality` goal; implement via `code_implementer` only after PH-UX gates.

## Control-plane UX surfaces (operator)

| Surface | Status | Evidence |
|---------|--------|----------|
| org-supervisor-dashboard | No swarm health / gap-apply panel | `apps/org-supervisor-dashboard/` |
| lic docs site | Pass (ux-audit + ui-audit) | `benchmarks/data/latest/ux-audit.json` |
| world-studio-demo harness | Linux audit OK; native pixels stub | `studio-ui-ux-builder-digest.md` |
| gap registry readability | Blocked — ingest cannot run | `swarm-gap-ingest.py` PyYAML |

## Recommended routing (no new agent ids)

1. `pr_merger` → lip#52 (merge-approved, gate-ready)
2. `ci_maintainer` → 12 repos missing CI
3. `gui_ux_tester` → studio-ux-16/17 + org-supervisor-dashboard UX audit
4. `gap_explorer` → after PyYAML + ingest green, refresh `swarm-gap-actions.json`
5. `plan_verifier` → refresh goal-directed snapshot; close orch-r3/r4 when evidence matches

## Evidence paths

- Report: `/app/data/runs/swarm_observer-1780919657792.md`
- Whitepaper staging: `docs/research/swarm_coverage/ux/2026-06-08-whitepaper-0e217961.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Registry: `data/swarm-gap-registry/registry.yaml`
- Briefing: `/workspace/benchmarks/data/latest/agent-briefing.json`
