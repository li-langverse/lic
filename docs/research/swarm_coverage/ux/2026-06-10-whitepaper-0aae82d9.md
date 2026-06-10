# Swarm gap orchestration — UX dimension

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `0aae82d9`  
**Date:** 2026-06-10  
**north_star_fit:** ecosystem, ai — easy operator surfaces for swarm health (Vision-LLM diagnostics)  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`

---

## Abstract

This pass audits swarm health through a **UX lens**: operator experience of the agent control plane — dashboards, briefing artifacts, gap visibility, and honest audit coverage. Grade holds at **C** (75.6, `unattended_safe: true`). **Orchestration UX blockers persist** from prior UX workers: missing control-plane mirrors, frozen gap ingest (PyYAML), and docs-only UX preflight. Agent execution is healthy; **operator honesty** is not.

---

## Operator UX posture

| Signal | Value | Source |
|--------|-------|--------|
| Control-plane reports | **Missing** | `/app/data/control-plane/` |
| Run telemetry sampled | **1** (this run, running) | `ecosystem-quality-report.json` |
| UX preflight targets | **1** (`lic-docs`) | `ux-audit.json` |
| GUI targets in handoff | **5** | `gui-ux-quality-handoff.md` |
| Open swarm gaps | **62** (stale @ 14:45Z) | `swarm-gap-actions.json` |
| `ui_ux` registry rows | **0** (studio = `plan_debt`) | `registry.yaml` |
| SDK auth | **OK** | `CURSOR_API_KEY` set |
| Briefing heap agents | **1** (`ci_maintainer`) | `agent-briefing.json` |
| Scorecard agents | **4** (+ gap_explorer, plan_verifier) | `ecosystem-quality-report.json` |

**Interpretation:** The swarm can run agents unattended, but operators cannot trust dashboard signals for gap freshness, retry budgets, or UX audit completeness.

---

## GUI product UX (secondary)

Reference sweep (2026-05-30): 4 pass, 1 skip (`agents-dashboard`), 0 fail. Current preflight (2026-05-30) validates **docs only**.

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
- **`orch-r3-missing-package-sweep`** — open; apply deferred. Route `gap-line-profiler-001` via `issue_planner`.

### Studio UI plan debt (runner `studio-ui-ux`, stopped)

- `studio-ux-16-palette-search-latency` — apply skip (missing backlog path)
- `studio-ux-17-gpu-fail-recovery` — apply skip (missing backlog path)

**Routing:** `studio_ui_ux_builder` when `STUDIO_UI_UX_PLAN_PATH` is set — not new systemd loops.

---

## Control-plane UX recommendations

1. **Persist observer state** — bootstrap `state.json` + `latest-report.json` on cold start so dashboard shows retry budgets and `swarm_degraded`.
2. **Unblock gap pipeline** — install `python3-yaml` in worker image; gap freshness is a primary operator signal.
3. **Align briefing with scorecard** — heap should surface all four recommended agents, not only `ci_maintainer`.
4. **Expand UX preflight** — proactive five-target GUI sweep; docs-only audit understates product UX debt.
5. **Mount studio plan** — enable gap-apply patches for `studio-ux-16/17`.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/ux-audit.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/app/data/runs/swarm_observer-1781123200634.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-10-orch-ux-0aae82d9.md`

---

## Related work

- Prior UX passes: `whitepaper-99a0e56b.md`, `whitepaper-abf20f4a.md`
- [research-verticals.md](../../../../li-cursor-agents/docs/ecosystem/research-verticals.md) — `swarm_coverage` + `ui_ux_quality` goals
- [swarm-architecture.md](../../swarm-architecture.md) — retired systemd loops → agents control plane
