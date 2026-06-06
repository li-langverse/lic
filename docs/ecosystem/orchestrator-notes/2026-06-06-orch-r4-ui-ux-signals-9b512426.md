# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Research dimension:** `ux` (worker `9b512426`)  
**Work item:** Surface studio-ui-ux / gui_ux_tester signals as ui_ux gaps; link studio backlog

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (64.8); `unattended_safe: false` |
| `orch-r4` | **Completed (signal routing)** — UX plan_debt rows mapped; handoffs enqueued |
| Studio runner | **Stopped** — 2 pending todos; 16/18 plan items done |
| Gap pipeline | **Blocked** — ingest SyntaxError; apply needs PyYAML; actions stale 2026-05-31 |
| Unattended? | **No** — CI failures + gap script bugs require human or control-plane fix |

---

## UX signals reconciled

### Open studio-ui-ux plan todos (snapshot)

| Todo id | Content | Gap registry row | Handoff |
|---------|---------|------------------|---------|
| `studio-ux-16-palette-search-latency` | Command palette fuzzy search + latency hook (UX-04) | `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `gui_ux_tester` → `code_implementer` |
| `studio-ux-17-gpu-fail-recovery` | Native GPU fail strip + retry (UX-08) | `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `gui_ux_tester` → `code_implementer` |

### Patched in gap-actions (pending implementation)

| Todo id | Backlog patch |
|---------|---------------|
| `studio-ux-21-wgpu-swapchain-gpu-runner` | `2026-05-24-studio-ui-ux-plan-loop.md` |
| `studio-ux-24-gpu-runner-deps` | `2026-05-24-studio-ui-ux-plan-loop.md` |

### Competitor / honesty gaps (UX-adjacent)

| Gap id | Title | Handoff |
|--------|-------|---------|
| `gap-vertical-stub-scientific-viz` | verticals.toml stub: scientific_viz | `gui_ux_tester`, `numerics_researcher` |

### Benchmark UX evidence gap

All `viz_*` catalog rows are **unknown** (no measured UX/viz perf): `viz_colormap`, `viz_inspector_panels`, `viz_linked_views`, `viz_marching_cubes`, `viz_pipeline_graph`, `viz_resample`, `viz_decimate` — see `agent-briefing.json` → `ecosystem_audit.benchmarks.unknown`.

---

## Swarm routing (no new systemd loops)

| Agent / goal | Action |
|--------------|--------|
| `gui_ux_tester` | Run `ui_ux_quality` goal — audit palette latency + GPU recovery against SOTA |
| `code_implementer` | Implement studio-ux-16/17 when gui_ux_tester hands off with evidence |
| `implementation_gaps` | Track studio-ux-21/24 via async implement lane |
| `ci_maintainer` | 3 repos missing CI (briefing P50) |
| `gap_explorer` | Refresh verticals.toml ingest after benchmarks main merge |
| `swarm_observer` | Re-run after ingest script fix |

Do **not** restart `studio-ui-ux` systemd plan loop — work routes via `li-cursor-agents` research/implement goals (`docs/ecosystem/swarm-architecture.md`).

---

## Scripts attempted

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# wrote ecosystem-quality-report.json — grade D

cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# FAILED: SyntaxError line 229 (unterminated string)

cd /workspace/lic && python3 scripts/swarm-gap-apply-actions.py
# FAILED: PyYAML required
```

---

## Registry plan-debt row

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — **close on next successful ingest** after this note + snapshot `completed_ids` update.

---

## Human-only

- Studio shell UX implementation (palette, GPU strip) — product PRs in lic-studio-ui
- benchmarks#371 (ux observer metrics PR) — CI triage before merge
- Fix `swarm-gap-ingest.py` before automated gap reconciliation resumes

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/data/goal-directed-agents/snapshot.json` (runners `studio-ui-ux`, `swarm-observer`)
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `li-cursor-agents/data/runs/swarm_observer-1780733386009.md`
- `lic/docs/research/swarm_coverage/ux/2026-06-06-whitepaper.md`
