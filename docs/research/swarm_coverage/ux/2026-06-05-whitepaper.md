# Swarm gap orchestration — UX dimension audit

**Goal:** `swarm_coverage` · **Dimension:** `ux` · **Worker:** `33107cb0`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`  
**north_star_fit:** ecosystem, ai — proof-before-perf; honest operator surfaces for agent swarm health

## Abstract

This pass audits whether Li's **swarm gap orchestration** pipeline produces trustworthy **operator UX signals**: studio plan todos, GUI audit targets, and registry taxonomy for `ui_ux` gaps. The ecosystem scorecard is **D (64.8)** with `unattended_safe: false`. Gap ingest is blocked by a SyntaxError (fixed locally) and missing PyYAML in the runner image, leaving 64 registry rows stale and zero `ui_ux` `gap_kind` entries.

## Method

1. Regenerated [`ecosystem-quality-report.json`](../../../../benchmarks/data/latest/ecosystem-quality-report.json).
2. Read [`registry.yaml`](../../../data/swarm-gap-registry/registry.yaml) and [`swarm-gap-actions.json`](../../../../benchmarks/data/latest/swarm-gap-actions.json).
3. Cross-checked studio UX plan loop and [`gui-ux-quality-handoff.md`](../../../ecosystem/gui-ux-quality-handoff.md).
4. Compared briefing `recommended_agents` vs scorecard dispatch.

## UX findings

### Studio UI plan debt (wave 3–4)

| Todo | State | Operator impact |
|------|-------|-----------------|
| `studio-ux-16` palette search latency | **open** | Cmd+K responsiveness unmeasured in CI |
| `studio-ux-17` GPU fail recovery | **open** | Agent error UX still mock-only (UX-08) |
| `studio-ux-21` wgpu swapchain | patched | GPU readback blocked on org runner |
| `studio-ux-24` GPU runner deps | patched | Vulkan matrix incomplete |

Evidence: [`2026-05-24-studio-ui-ux-plan-loop.md`](../../../superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md), iteration reports under `docs/reports/studio-ui-ux/iterations/`.

### GUI audit coverage

Per 2026-05-30 proactive sweep (see handoff doc):

- `agents-dashboard` — **skip** (dev server port mismatch)
- `world-studio-demo` — pass but **Partial** (HTML mock)
- `world-studio-native` — pass with `LIC_ROOT=lic-studio-ui`

Swarm observer cannot close `orch-r4-ui-ux-signals` until ingest runs with PyYAML.

### Registry taxonomy gap

`swarm-gap-actions.by_kind` lacks `ui_ux`. Studio todos are `plan_debt`; competitor viz stubs (`scientific_viz`, `cinematic_*`) are `competitor_feature`. Recommend explicit `ui_ux` rows on next ingest for dashboard and native-studio journeys.

## Recommendations

1. **`gui_ux_tester`** on `ui_ux_quality` goal — `studio-ux-16/17` acceptance harnesses.
2. **`li-cursor-agents`** — bake PyYAML; persist control-plane `latest-report.json` on Job exit.
3. **`benchmarks`** — unblock PH-5b catalog PRs before metrics refresh merges.
4. **No new systemd loops** — route via `config/research-goals.yaml` async swarm.

## Evidence index

| Path | Role |
|------|------|
| `/app/data/runs/swarm_observer-1780633576702.md` | Observer digest |
| `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-05-orch-swarm-coverage-ux-33107cb0.md` | Orchestrator note |
| `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` | Scorecard |
| `/workspace/lic/data/swarm-gap-registry/registry.yaml` | Gap registry |

## Deferred publish

Copy to `research-findings` when repo is mounted in org-research Job.
