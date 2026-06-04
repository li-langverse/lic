# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-04 · **Agent:** `swarm_observer` · **Goal:** `swarm_coverage@ux` · **Worker:** `e7d539d8`  
**north_star_fit:** ecosystem, ai — easy operator UX for swarm gap orchestration (Vision-LLM diagnostics)

## Context

Swarm observer pass under research goal `swarm_coverage`, UX dimension. Registry todo `orch-r4-ui-ux-signals` remains **open** because goal-directed snapshot (`lic/data/goal-directed-agents/snapshot.json`) is stale (2026-05-30) and gap apply pipeline is blocked (ingest syntax + missing PyYAML in org-research pod).

## UX signals reconciled

| Signal | Measured / shipped | Registry row | Action |
|--------|-------------------|--------------|--------|
| Palette open/filter latency | 12 ms / 8 ms (budgets 50/30 ms) | `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | **Close** after snapshot refresh — evidence: `docs/reports/studio-ui-ux/iterations/20260530T092400Z-studio-ux-16-palette-search-latency.md` |
| GPU fail recovery strip | 15 ms retry (budget 100 ms) | `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | **Close** after snapshot refresh — evidence: `…/20260530T120800Z-studio-ux-17-gpu-fail-recovery.md` |
| wgpu swapchain GPU runner | Pending implementation | `studio-ux-21`, `studio-ux-24` | Patch plan file; handoff `ui_ux_quality` → `studio_ui_ux_builder` |
| Swarm operator dashboard | No gap-apply / grade panel | `orch-r4-ui-ux-signals` | Handoff `li-cursor-agents` dashboard + persist CP disk cache |
| GUI audit honesty | agents-dashboard Partial (#38) | `gap-ux-audit-agents-dashboard` | Handoff `gui_ux_tester` full sweep |

## Gap taxonomy (UX)

| `gap_kind` | Primary discoverer | Route |
|------------|-------------------|-------|
| `ui_ux` | `gui_ux_tester` / studio-ui loop | Link `2026-05-24-studio-ui-ux-plan-loop.md` todos; no new systemd loops |
| `plan_debt` | `plan_verifier` | Refresh snapshot → registry dedupe |
| `competitor_feature` | `gap_explorer` | Research goals, not studio product code in this note |

## Handoffs (async swarm — not lic systemd loops)

1. **`gui_ux_tester`** — run full GUI target matrix per `docs/ecosystem/gui-ux-quality-handoff.md`; score UX-01…UX-14.
2. **`ui_ux_quality` research goal** — audit docs/TUI/GUI vs SOTA; publish under `research-findings/whitepapers/…/ui_ux_quality/`.
3. **`issue_planner`** — lic#575 close criteria after snapshot proves studio-ux-16/17 done.
4. **`code_implementer`** — typography FX (lic#742, studio#67) from remediation manifest.
5. **`swarm_observer`** — re-run apply after PyYAML + ingest fix merged; then mark `orch-r4` completed in swarm-observer plan backlog.

## Blockers

- `swarm-gap-ingest.py` L229 syntax (fixed 2026-06-04, pending merge)
- PyYAML missing in org-research Job image
- Stale goal-directed snapshot (4+ days)
- MCP Supabase down — cannot verify `agent_runs` history

## Evidence paths

- `benchmarks/data/latest/ecosystem-quality-report.json` (grade D, 67.8)
- `benchmarks/data/latest/swarm-gap-actions.json` (64 open, stale)
- `lic/data/swarm-gap-registry/registry.yaml`
- `data/runs/swarm_observer-1780538397768.md` (li-cursor-agents pod)
