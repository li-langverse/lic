# Swarm gap orchestration — UX dimension audit

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `3e31cffe`  
**Date:** 2026-06-07  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`  
**north_star_fit:** ecosystem, ai — **easy** pillar (accessible, honest UX signals)

---

## Abstract

This audit maps UX-related swarm gaps to orchestration actions without shipping product UI code in `lic`. The benchmarks org dashboard exhibits a **redundant PR stack** (GPU chip picker ARIA/WCAG, #400–409) that blocks clean agent handoffs. Two **studio-ui-ux** plan todos remain open in the gap registry. Gap ingest/apply is operational after control-plane fixes; studio-ui backlog patching requires mounting `lic-studio-ui`.

---

## Evidence summary

| Signal | Value | Path |
|--------|-------|------|
| Ecosystem grade | D (60.9) | `benchmarks/data/latest/ecosystem-quality-report.json` |
| Open gaps | 62 | `benchmarks/data/latest/swarm-gap-actions.json` |
| Failed UX PRs | 8+ (GPU picker) | `benchmarks/data/latest/agent-briefing.json` |
| Studio UX todos open | 2 | `lic/data/swarm-gap-registry/registry.yaml` |
| Swarm execution blind spot | `runs_sampled=0` | scorecard inputs |

---

## UX gap taxonomy (this run)

| Class | Example | Discoverer | Orchestrator action |
|-------|---------|------------|---------------------|
| `ui_ux` plan_debt | `studio-ux-16`, `studio-ux-17` | `plan_verifier` | Dispatch `gui_ux_tester` |
| External CI UX debt | benchmarks#400–409 | agents + human | Consolidate PR stack |
| Infra blocking honest UX | `verticals.toml` missing on main | `gap_explorer` | `gap_explorer` + docs PR |
| Meta orch debt | `orch-r4-ui-ux-signals` | `plan_verifier` | This whitepaper + note |

---

## Recommendations

1. **Consolidate** benchmarks GPU chip picker PRs before re-running `gui_ux_tester`.
2. **Mount** `LIC_STUDIO_UI_ROOT` so gap-apply can patch studio-ui plan loop backlogs.
3. **Dispatch** `gui_ux_tester` on cadence when registry rows for `studio-ui-ux` are open.
4. **Fix** scorecard `runs_dir` so swarm_execution dimension reflects container layout.
5. **Publish** this staging doc to `research-findings` when repo is available.

---

## Related artifacts

- Run report: `/app/data/runs/swarm_observer-1780801805718.md`
- Orchestrator note: `lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r4-ui-ux-signals-3e31cffe.md`
- Vertical context: `li-cursor-agents/docs/ecosystem/research-verticals.md` (`ui_ux_quality` goal)
