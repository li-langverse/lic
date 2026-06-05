# Orchestrator note — `swarm_coverage@ux` (worker `33107cb0`)

**Date:** 2026-06-05  
**Goal:** `swarm_coverage` · **Dimension:** `ux`  
**north_star_fit:** ecosystem, ai — operator-facing swarm diagnostics must be honest and low-friction (Vision-LLM partial)

## Evidence

| Artifact | Path |
|----------|------|
| Ecosystem scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (64.8, D, `unattended_safe: false`) |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` (64 open) |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Studio UX plan | `/workspace/lic/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` |
| UX handoff routing | `/workspace/lic/docs/ecosystem/gui-ux-quality-handoff.md` |
| Observer digest | `/app/data/runs/swarm_observer-1780633576702.md` |

## UX gap reconcile (Mode B)

### Open studio-ui `plan_debt` → swarm agents

| Plan todo | Registry gap | Route | Notes |
|-----------|--------------|-------|-------|
| `studio-ux-16-palette-search-latency` | `gap-plan-pending-studio-ui-ux-studio-ux-16-*` | `gui_ux_tester` via `ui_ux_quality` | Cmd+K palette latency harness; UX-04 rubric |
| `studio-ux-17-gpu-fail-recovery` | `gap-plan-pending-studio-ui-ux-studio-ux-17-*` | `gui_ux_tester` | Native GPU fail strip; UX-08 |
| `studio-ux-21-wgpu-swapchain-gpu-runner` | patched in plan loop | `studio_ui_ux_builder` | Blocked on org GPU runner |
| `studio-ux-24-gpu-runner-deps` | patched in plan loop | `studio_ui_ux_builder` | Vulkan + `LIG_WGPU_SWAPCHAIN` CI |

### `orch-r4-ui-ux-signals` (open)

Pending ingest of `gap-ux-*` rows with `gap_kind: ui_ux` per [`gui-ux-quality-handoff.md`](../gui-ux-quality-handoff.md):

- `gap-ux-audit-agents-dashboard` → `gui_ux_tester` (dashboard empty state / live stream)
- `gap-ux-audit-native-studio` → `studio_ui_ux_builder`
- `gap-ux-audit-world-studio-demo` → **Partial** — HTML mock until native harness

**Blocker:** `swarm-gap-ingest.py` requires PyYAML; L229 syntax fixed this pass but ingest did not run.

### Competitor stub with UX lens

| Gap | UX impact |
|-----|-----------|
| `gap-vertical-stub-scientific-viz` | Honest viz bench vs matplotlib/plotly class surfaces |
| `gap-vertical-stub-cinematic-*` | Media pipeline UX stubs — defer to `goal_researcher` / gaming vertical |

## Control-plane actions (no product code in `lic`)

1. Merge ingest syntax fix on `lic` (`scripts/swarm-gap-ingest.py:229`).
2. Bake `python3-yaml` in org-research Job image (`li-cursor-agents`).
3. Enqueue `gui_ux_tester` on `ui_ux_quality` goal for `studio-ux-16/17` (heap currently favors `ci_maintainer`).
4. Do **not** install retired `studio-ui-ux` systemd plan loop — async swarm only ([`swarm-architecture.md`](https://github.com/li-langverse/li-cursor-agents/blob/main/docs/ecosystem/swarm-architecture.md)).

## Handoffs (cite north_star_fit)

| To | Why |
|----|-----|
| `gui_ux_tester` | Close studio-ux-16/17; five-target GUI sweep |
| `ci_maintainer` | Unblock benchmarks metrics PR CI; 3 repos missing CI |
| `security_auditor` | 19 CWE catalog gaps |
| `gap_explorer` | Reconcile 64 registry rows after ingest unblocked |
