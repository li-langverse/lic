# Swarm gap orchestration — UX dimension audit

**Goal:** `swarm_coverage`  
**Dimension:** ux  
**Date:** 2026-06-06  
**Agent:** `swarm_observer` (worker `e70fed9c`)  
**north_star_fit:** ecosystem, ai — orchestration visibility and user-facing surface coverage

> Staging copy for `research-findings/whitepapers/2026-06/swarm_coverage/ux/` — publish when PR lane clears.

---

## Abstract

This audit evaluates whether the Li agent swarm's **gap orchestration pipeline** exposes sufficient **UX signals** for unattended operation: dashboard benchmark visibility, docs/GUI audit coverage, and studio-ui plan debt routing. Grade **D (62.6)** with `unattended_safe: false`. Gap ingest/apply was recovered during the run; studio-ui backlog patching remains blocked without `lic-studio-ui` mount.

---

## Method

1. Regenerated `ecosystem-quality-report.json` from live briefing + gap actions.
2. Compared briefing `recommended_agents` vs scorecard recommendations (drift analysis).
3. Ran `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` after fixing ingest Path fallback.
4. Reviewed `ux-audit.json`, `ui-audit.json`, and `viz_*` unknown benchmark rows.
5. Sampled studio-ui-ux registry rows and apply skip logs.

---

## Findings

### Orchestration UX (operator-facing)

| Signal | Observation |
|--------|-------------|
| Control-plane artifacts | `latest-report.json` / `state.json` missing — operator dashboard cannot show retries/interventions |
| Run history | `runs_sampled: 0` in fresh container — scorecard cannot assess error streaks |
| Briefing vs scorecard | Top-3 briefing agents omit meta healers when grade < C |

### User-facing surface UX

| Surface | Audit status |
|---------|--------------|
| lic-docs (MkDocs) | Pass — rubric 0.7–0.9, mobile nav OK |
| Viz benchmarks (7) | Unknown — charts show gaps without honest stub oracles |
| Studio UI plan loop | 17 registry rows; backlog file missing |
| Dashboard charts | 12 P1 `chart_pending` items |

### Gap pipeline UX

- **Before run:** ingest SyntaxError + PyYAML missing → operator sees stale 64-gap snapshot.
- **After run:** 62 open gaps; apply patches sim/security backlogs; studio rows skipped with explicit log lines.

---

## Recommendations

1. **Persist control-plane state to disk** when DB unavailable — critical for operator trust.
2. **Bake PyYAML** in org-research worker — eliminate silent gap-pipeline failure.
3. **Dispatch `gui_ux_tester`** on `ui_ux_quality` cadence; extend audits beyond static docs.
4. **Register `viz_*` stub oracles** — convert unknown rows to honest pending charts.
5. **Mount `lic-studio-ui`** plan backlog or add fallback path in apply script.

---

## Evidence index

| Artifact | Path |
|----------|------|
| Scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| UX audit | `/workspace/benchmarks/data/latest/ux-audit.json` |
| Observer digest | `/app/data/runs/swarm_observer-1780751391363.md` |
| Orchestrator note | `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r4-ui-ux-signals.md` |

---

## north_star_fit

**Domains:** ecosystem, ai  
**Pillar alignment:** Easy (operator UX, docs pass) · Provable (no unproved viz claims — honest unknowns) · Fast (deferred until catalog complete)
