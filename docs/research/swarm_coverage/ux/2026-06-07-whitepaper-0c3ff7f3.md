# Swarm coverage — UX dimension whitepaper

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `0c3ff7f3`  
**Date:** 2026-06-07  
**north_star_fit:** ecosystem, ai — easy pillar (operator surfaces + studio UX SOTA)

## Abstract

The Li agent swarm's **operator UX** (dashboards, briefing surfaces, gap orchestration tooling) and **product UX signals** (studio shell, benchmarks dashboard accessibility) are decoupled from execution health. Swarm execution scores 100/100 this cycle, but ecosystem quality is **grade D (69.6)** with `unattended_safe=false` because control-plane persistence, gap ingest dependencies, and stale goal-directed snapshots block self-healing UX workflows.

## Method

1. Regenerated `ecosystem-quality-report.json` with `LI_CURSOR_AGENTS_ROOT=/app`.
2. Compared briefing `recommended_agents` vs scorecard recommendations.
3. Audited swarm-gap registry for `ui_ux` / `plan_debt` studio rows vs plan-loop ground truth.
4. Sampled `agent-briefing.json` failed PRs for dashboard ARIA regressions.
5. Reviewed supervisor audit logs (`org-research-audit.jsonl`, `org-swarm-stability-audit.jsonl`).

## Findings

### Operator UX (control plane)

| Surface | Issue | Impact |
|---------|-------|--------|
| Control-plane state | `state.json` / `latest-report.json` absent until observer bootstrap | Dashboard cannot show retry_counts or interventions |
| Gap tooling | PyYAML missing in worker; ingest syntax error on L229 (fixed) | 64 gaps cannot refresh; orch-r4 blocked |
| Briefing preflight | 8 scripts `--skip-slow`; 2 failed | Stale plan/security signals |
| Runs sampling | `runs_sampled=1` (thin window) | Scorecard overweights single active run |

### Product UX signals (studio + benchmarks)

| Area | Evidence | Severity |
|------|----------|----------|
| Benchmarks GPU picker | 5+ PRs (#404–409) failing CI on ARIA tabs (#147) | high |
| Studio palette latency | `studio-ux-16` done in plan; open in snapshot | medium (stale data) |
| GPU fail recovery | `studio-ux-17` done in plan; open in snapshot | medium |
| Scientific viz stubs | `gap-vertical-stub-scientific-viz` competitor_feature | low (honesty gap) |

### Goal orientation

Briefing heap prioritizes `pr_merger` → `ci_maintainer` → `security_auditor`. Scorecard adds `gap_explorer`, `ecosystem_grader`, `plan_verifier`. No conflict — UX orchestration (`orch-r4`) is meta-layer work the briefing does not surface directly.

## Recommendations

1. **Bake `python3-yaml`** in org-research worker (`li-cursor-agents` deploy).
2. **Merge lic ingest fix** (L229 Path fallback) — unblocks verticals.toml stub ingest.
3. **Refresh goal-directed snapshot** — reconcile studio-ui-ux completed todos.
4. **Consolidate benchmarks#404–409** into one green ARIA PR.
5. **Dispatch `gui_ux_tester`** on `ui_ux_quality` goal after ingest green.
6. **Observer persist CP state** each supervisor tick (`src/observer/` + `data/control-plane/`).

## Publish path

Staging: `lic/docs/research/swarm_coverage/ux/2026-06-07-whitepaper-0c3ff7f3.md`  
Target: `research-findings/whitepapers/2026-06/swarm_coverage/ux/` (repo not mounted this run).

## References

- `docs/ecosystem/research-verticals.md` — `ui_ux_quality`, `swarm_coverage` goals
- `config/research-goals.yaml` — agent routing
- `lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r4-ui-ux-signals-0c3ff7f3.md`
