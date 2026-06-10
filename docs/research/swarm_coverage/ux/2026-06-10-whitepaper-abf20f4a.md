# Swarm gap orchestration — UX dimension

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `abf20f4a`  
**Date:** 2026-06-10  
**north_star_fit:** ecosystem, ai — easy operator surfaces for swarm health (Vision-LLM diagnostics)  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`

---

## Abstract

This pass audits swarm health through a **UX lens**: operator experience of the agent control plane — dashboards, briefing artifacts, gap visibility, and honest audit coverage. Grade improved to **C** (75.6, `unattended_safe: true`) vs prior UX pass **D** (67.3), but **orchestration UX blockers persist**: missing control-plane mirrors, frozen gap ingest, and docs-only UX preflight.

---

## Operator UX posture

| Signal | Value | Source |
|--------|-------|--------|
| Control-plane reports | **Missing** | `/app/data/control-plane/` |
| Run telemetry sampled | **1** (this run, running) | `ecosystem-quality-report.json` |
| UX preflight targets | **1** (`lic-docs`) | `ux-audit.json` |
| GUI targets in handoff | **5** | `gui-ux-quality-handoff.md` |
| Open swarm gaps | **62** (stale @ 03:54Z) | `swarm-gap-actions.json` |
| `ui_ux` registry rows | **0** (studio = `plan_debt`) | `registry.yaml` |
| SDK auth | **OK** | `CURSOR_API_KEY` set |

**Interpretation:** Agent execution is healthy; **operator honesty** is not — stale gaps and missing CP state prevent unattended trust in dashboard signals.

---

## GUI product UX (secondary)

Reference sweep (2026-05-30): 4 pass, 1 skip (`agents-dashboard`), 0 fail. Current preflight (2026-05-30/31) validates **docs only**.

| Target | Status | Honesty |
|--------|--------|---------|
| `lic-docs` | pass | static site only in current preflight |
| `agents-dashboard` | skip | dev server / port ([#38](https://github.com/li-langverse/li-cursor-agents/issues/38)) |
| `world-studio-demo` | pass | HTML mock — Partial |
| `world-studio-native` | pass | SDL with `LIC_ROOT=lic-studio-ui` |
| `lic-tetris` | pass* | *studio stub — not real game |

Wave-2 studio todos (`studio-ux-16`, `studio-ux-17`) blocked on unmounted `lic-studio-ui` plan loop.

---

## Gap registry — UX-relevant rows

### Swarm observer plan debt

- **`orch-r4-ui-ux-signals`** — open; apply deferred. **Reconcile:** link to `ui_ux_quality` research goal → `gui_ux_tester` handoff; ingest five handoff-documented `gap-ux-*` rows on next successful ingest.

### Studio UI plan debt (runner `studio-ui-ux`, stopped)

- `studio-ux-16-palette-search-latency` — apply skip (missing backlog path)
- `studio-ux-17-gpu-fail-recovery` — apply skip (missing backlog path)

### Handoff-documented UX gaps (ingest target)

- `gap-ux-audit-native-studio`, `gap-ux-audit-agents-dashboard`, `gap-ux-audit-world-studio-demo`, `gap-ux-studio-wave2-plan`, `gap-ux-cinematic-studio-handoff`

---

## Orchestration blockers (UX of the swarm itself)

1. **PyYAML missing** — gap ingest/apply cannot refresh; operators see stale 03:54Z actions.
2. **CP mirrors absent** — no persisted observer state or intervention log.
3. **`LI_CURSOR_AGENTS_ENABLED=0`** — deliverable gate skipped in briefing.
4. **Briefing/scorecard agent drift** — `gap_explorer` missing from heap despite gap_pressure=60.

---

## Recommendations

1. Persist CP state + latest report for dashboard consumption.
2. Proactive five-target GUI sweep in briefing (not docs-only).
3. Mount `lic-studio-ui` for gap apply; complete `orch-r4` via `ui_ux_quality` goal.
4. Bake `PyYAML` into worker image; re-run ingest after deploy.

---

## Evidence

- `/app/data/runs/swarm_observer-1781085267779.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-10-orch-ux-abf20f4a.md`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/docs/ecosystem/gui-ux-quality-handoff.md`
