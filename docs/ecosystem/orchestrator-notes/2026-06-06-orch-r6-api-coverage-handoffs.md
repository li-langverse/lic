# Orchestrator note — orch-r6 api-coverage handoffs

**Date:** 2026-06-06  
**Goal:** `swarm_coverage@api-coverage`  
**Worker:** `eb17377e`  
**north_star_fit:** ecosystem + ai — swarm control-plane API surfaces and server/stdlib benchmark coverage

## Context

Swarm observer pass found grade **D (62.6)**, `unattended_safe: false`. Gap ingest was failing on `swarm-gap-ingest.py` L229 (syntax) and missing `BENCHMARKS_COMPETITIVE` default. Fixed and re-ran ingest + apply in org-research pod.

## api-coverage gap reconcile

| Signal | Count | Route |
|--------|-------|-------|
| `chart_pending` httpd workloads | 9 | `goal_researcher` → `server_platform`; evidence via `bench_improver` |
| `chart_pending` stdlib | 3 | `stdlib_researcher` → `stdlib_ecosystem` |
| `sec-r1-httpd-fuzz-smoke` | 1 plan_debt | `security_auditor` → `offensive_security` |
| Phase H li-httpd M1 | 1 plan_debt | `plan_verifier` — blocked on master-plan 2e–2f |
| Org repos HTTP 404 | 6 | `issue_planner` + roadmap — do not invent CI for missing repos |

## Handoffs (swarm goals — no new agent ids)

1. **security_auditor** — run `offensive_security` goal; execute `sec-r1-httpd-fuzz-smoke` from `security-research-backlog.md`.
2. **stdlib_researcher** — audit `stdlib_binary_search`, `stdlib_dict_insert_lookup`, `stdlib_sort_int` chart_pending rows; cite PH-IO ids on handoff.
3. **goal_researcher** — `server_platform` whitepaper slice for httpd competitive charts (static, LB, rate-limit).
4. **gap_explorer** — after ingest stable, close competitor_feature rows with bench evidence or stub-honest catalog entries.
5. **ci_maintainer** — triage 6 incomplete repo audits; do not count 404 as “missing CI on main” without repo existence check.

## Control-plane (no lic product code)

- Merge ingest fix to `lic` main.
- Bake `python3-yaml` in org-research worker image (`li-cursor-agents` deploy).
- Persist observer CP artifacts to disk when Supabase unavailable.

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/dashboard-gap-report.json`
- `/workspace/benchmarks/data/latest/org-repo-ci-audit.json`
- `/app/data/runs/swarm_observer-1780753191336.md`
