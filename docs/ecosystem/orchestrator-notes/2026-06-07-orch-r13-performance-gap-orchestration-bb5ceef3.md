# Orchestrator note — orch-r13 performance gap orchestration

**Date:** 2026-06-07  
**Worker:** `bb5ceef3`  
**Goal:** `swarm_coverage` @ `performance`  
**north_star_fit:** ecosystem, ai — proof-before-perf (PH-7e numerics, httpd wrk soak)

## Prep confirmed

| Step | Status | Evidence |
|------|--------|----------|
| `swarm-gap-ingest.py` | **REMEDIATED** (SyntaxError line 229 + `BENCHMARKS_COMPETITIVE` KeyError) | `/workspace/lic/scripts/swarm-gap-ingest.py` |
| `swarm-gap-apply-actions.py` | **OK** (PyYAML via ephemeral `pip install`) | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Ecosystem quality grade | **Refreshed** | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |

Registry after ingest: **92** rows (`missing_package` 5, `plan_debt` 57, `competitor_feature` 30).  
Apply output: **62** open gaps with **23** backlog patches.

## Performance gap reconcile

| `gap_kind` | Gap / signal | Route | Handoff |
|------------|--------------|-------|---------|
| `plan_debt` | `gap-phase2-perf-wrk-soak` (httpd runner) | `httpd` plan loop via control plane | `code_implementer` on `cursor/httpd-plan-continue` |
| `competitor_feature` | `gap-benchmark-red-*` tier-1 reds (matmul, gmres, integrators) | `sim-algorithm-backlog.md` | `bench_improver` + `numerics_researcher` (`numerics_sota`, PH-7e) |
| `competitor_feature` | Yellow: `num_eig_symmetric`, `num_root_newton` | benchmarks matrix | `bench_improver` — proof-before-perf, no unsafe shortcuts |
| `competitor_feature` | Near-threshold (1.18–1.20× cpp): BFGS, RK4, Euler, CG | benchmarks matrix | `autoresearch` after yellow closed |
| `plan_debt` | `orch-r3-missing-package-sweep`, `orch-r4-ui-ux-signals` | deferred until snapshot refresh | `swarm_observer` next cadence |
| `missing_package` | `li-line-profiler` | `ecosystem-package-backlog.md` | `issue_planner` |

## Control-plane fixes (not lic product)

1. Bake `python3-yaml` + `LI_CURSOR_AGENTS_ROOT=/app` in org-research worker image.
2. Observer: persist `state.json` + `latest-report.json` each supervisor tick.
3. Fix `runs_dir` default — grader sampled **0** runs (`/workspace/li-cursor-agents/data/runs` vs `/app/data/runs`).

## Human-only

- Merge lip#52 (deps bump) — `pr_merger` queue head, gate-ready.
- CWE Top-25 catalog backfill (19 rows) — governance.
- `trusted.lean` / provability PRs — human-approved issues only.

## Next dispatch

`pr_merger` → `ci_maintainer` → `bench_improver` + `numerics_researcher` → `gap_explorer` → `security_auditor`
