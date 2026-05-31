# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-05-31  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, easy, ai-first)  
**Work item:** Link docs + GUI UX audit signals to swarm gap taxonomy; route P0 blockers without new systemd loops

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **C** (72.8); `unattended_safe: false` |
| `orch-r4` | **Completed** — docs + GUI digests harvested; registry has 0 open `ui_ux` rows |
| Docs UX | Local harness **pass**; live Pages **fail** (lic#403) |
| GUI UX | 4/5 targets **pass**; `agents-dashboard` **skip** ([#38](https://github.com/li-langverse/li-cursor-agents/issues/38)) |
| Unattended? | **Not safe** — P0 docs deploy + dashboard server require human/ci action |

---

## UX signal reconciliation

| Surface | Agent run | Digest | P0 finding | Handoff |
|---------|-----------|--------|------------|---------|
| Docs (`lic-docs`) | `docs_ux_tester-1780189345` | `benchmarks/docs/ecosystem/ux-digests/2026-05-31-docs-ux.md` | Live Pages stale (5 vs 12 tabs); search 248 vs 2801 | `docs_maintainer` + lic#403 |
| GUI (Studio) | `gui_ux_tester-1780189300` | `benchmarks/docs/ecosystem/ux-digests/2026-05-31-gui-ux.md` | Palette latency pass (studio-ux-16); dashboard skip | `studio_ui_ux_builder` + li-cursor-agents#38 |
| Plan loop | studio-ux-16/17 patched | `2026-05-24-studio-ui-ux-plan-loop.md` | UX-17 GPU fail recovery open | `gui_ux_tester` on next cycle |

Preflight artifacts:

- `benchmarks/data/latest-docs-ux-run/ux-audit.json` — pass @ 01:02Z
- `benchmarks/data/latest-gui-ux-run/ux-audit.json` — 4 pass, 1 skip @ 01:01Z

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `docs_maintainer` | Unblock lic#403 strict CI → Pages deploy |
| `gui_ux_tester` | Re-run when agents-dashboard server up; studio-ux-17 GPU fail |
| `docs_ux_tester` | Periodic proactive refresh (cadence in research goals) |
| `issue_planner` | IA fix lic#422 (language ref under Game dev tab) |

Briefing preflight gap: org `data/latest/ux-audit.json` is docs-only — track li-cursor-agents#32 for GUI rows in briefing.

---

## Registry plan-debt row

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — **close on next ingest** after snapshot records `orch-r4` in `completed_ids` (this note is completion evidence).

---

## Human-only

- lic#403 Pages deploy — requires CI green on `main`, not auto-merge from agent sweep
- Merge studio-ux-16 PR on `cursor/studio-ui-ux-plan-loop` — human review
- agents-dashboard process — ops/start before live UX-06/07/11 audit

---

## Evidence paths

- `benchmarks/data/runs/docs_ux_tester-1780189345.md`
- `benchmarks/data/runs/gui_ux_tester-1780189300.md`
- `benchmarks/data/runs/swarm_observer-1780189441014.md`
- `benchmarks/data/latest/ecosystem-quality-report.json`
