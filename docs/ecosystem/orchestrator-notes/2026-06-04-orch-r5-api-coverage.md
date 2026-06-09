# Orchestrator note — `orch-r5` api-coverage gap pipeline

**Date:** 2026-06-04T03:10Z  
**Agent:** `swarm_observer` (worker `10144f5a`)  
**Research goal:** `swarm_coverage@api-coverage`  
**north_star_fit:** ecosystem orchestration — MCP/read-path coverage for gap registry + control plane (proof → easy → fast)

## Context

Org-research dimension **`api-coverage`** audits whether agents can **read** briefing, scorecard, gap registry, and control-plane state without brittle local paths. This cycle unblocks **`swarm-gap-ingest.py`** vertical stub ingest and confirms apply-actions output.

## Actions taken

| Step | Result | Evidence |
|------|--------|----------|
| Fix `BENCHMARKS_COMPETITIVE` default in `ingest_verticals_stubs` | Syntax + fallback cascade | `lic/scripts/swarm-gap-ingest.py` L226–235 |
| Install `python3-yaml` on runner | Ingest/apply runnable | apt `python3-yaml` |
| `swarm-gap-ingest.py` | Registry **92** rows; **0** new vertical stubs (file found) | `lic/data/swarm-gap-registry/registry.yaml` |
| `swarm-gap-apply-actions.py` | **62** open gaps; **23** backlog patches | `benchmarks/data/latest/swarm-gap-actions.json` |
| Scorecard refresh | **67.3** grade **D**; `unattended_safe: false` | `benchmarks/data/latest/ecosystem-quality-report.json` |

## api-coverage findings

| Surface | Status | Gap |
|---------|--------|-----|
| `li-control-plane-db` MCP (`query_control_plane_db`, …) | **Unavailable** — `ECONNREFUSED :54322` | No PostgREST fallback in Job |
| On-disk CP mirrors (`latest-report.json`, `state.json`) | **Missing** under `/app/data/control-plane/` | Observer cannot read programmatic heal state |
| `li-ecosystem-context` MCP | **Ready** — briefing, handoffs, `describe_package` | No `read_ecosystem_quality_report` / `read_swarm_gap_registry` tools |
| `BENCHMARKS_COMPETITIVE` → `verticals.toml` | **Fixed** default → `benchmarks/workloads/competitive` | Merge lic ingest fix (open PRs #799–#807) |
| `swarm-gap-apply` studio-ui backlogs | **Skipped** — `lic-studio-ui` not mounted | Org-research Job volume map |
| Local `runs_dir` (`/workspace/li-cursor-agents/data/runs`) | **Empty** in Job — 0 runs sampled | Grader `swarm_execution` blind |

## Open gap reconcile (api-coverage lens)

| `gap_kind` | Open | Route (no new registry ids) |
|------------|------|-----------------------------|
| `missing_package` | 1 (`gap-line-profiler-001`) | `ecosystem-package-backlog.md` → **`issue_planner`** |
| `plan_debt` | 31 | **`plan_verifier`** + **`implementation_gaps`**; sim/security backlogs patched |
| `competitor_feature` | 30 | **`gap_explorer`** + **`bench_improver`**; verticals ingest unblocked |

**orch-r3** (missing-package): std.summary/plot closed in registry — only line_profiler seed remains open.  
**orch-r4** (ui_ux): deferred — studio-ui plan loop not mounted on this Job.

## Handoffs

- **`gap_explorer`** — refresh competitor catalog after verticals.toml ingest path stable  
- **`ci_maintainer`** — 1 repo missing CI on main (briefing P0)  
- **`security_auditor`** — 19 Top25 CWEs missing from catalog (briefing P0)  
- **`issue_planner`** — `gap-line-profiler-001` package seed  
- **`plan_verifier`** — stale goal-directed snapshot (2026-05-30); refresh plan audit preflight  

Do **not** recommend `install-goal-plan-loop-systemd.sh` — use `li-cursor-agents` research/implement goals only.

## Human-only

- Merge lic ingest fix PR; bake `python3-yaml` in org-research image  
- Restore Supabase / persist CP disk cache on Jobs  
- Governance PRs, **trusted.lean**, benchmarks CI-red merge wave (#306–#314)
