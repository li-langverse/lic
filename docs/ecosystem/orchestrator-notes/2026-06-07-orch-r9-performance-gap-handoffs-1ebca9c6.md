# Orchestrator note — orch-r9 performance gap handoffs

**Date:** 2026-06-07  
**Run:** `swarm_observer-1780814409270` · worker `1ebca9c6`  
**Goal:** `swarm_coverage` · dimension `performance`  
**north_star_fit:** ecosystem, ai — PH-7e (SIMD/parallel lowering), PH-5b (numerics/HPC), Phase 8p (CI throughput)

## Context

Fresh ecosystem grade: **60.9 / D**, `unattended_safe=false` (`benchmarks/data/latest/ecosystem-quality-report.json`). Briefing heap prioritizes `pr_merger` (lip#52) and `ci_maintainer` (14 repos missing CI). Gap registry holds **62 open** rows after ingest+apply.

## Self-heal actions (this cycle)

| Action | Result | Evidence |
|--------|--------|----------|
| Regenerate ecosystem grade | OK | `benchmarks/data/latest/ecosystem-quality-report.json` |
| Fix `swarm-gap-ingest.py` syntax + env fallback | OK | `lic/scripts/swarm-gap-ingest.py` |
| Install `python3-yaml`; run ingest | OK | `lic/data/swarm-gap-registry/registry.yaml` (92 rows) |
| Run gap apply | OK | `benchmarks/data/latest/swarm-gap-actions.json` (62 open) |
| Bootstrap control-plane disk cache | OK | `li-cursor-agents/data/control-plane/{state,latest-report}.json` |

## Performance-gap reconcile (open → handoff)

| Gap id | Kind | Priority | Handoff | Route |
|--------|------|----------|---------|-------|
| `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` | plan_debt | 7 | `bench_improver`, `numerics_researcher` | httpd runner; wrk soak vs nginx — proof-before-perf gate |
| `gap-plan-pending-httpd-gap-phase2-streaming-wrk` | plan_debt | 7 | `bench_improver` | SSE/WS timing parity; blocks streaming perf evidence |
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | plan_debt | 7 | `numerics_researcher`, `code_implementer` | `sim-algorithm-backlog.md` patched pending |
| `gap-benchmark-red-matmul-naive-tier1` | competitor_feature | 8 | `bench_improver`, `numerics_researcher` | 1.73× vs cpp — PH-7e |
| `gap-benchmark-red-num-gmres-tier1` | competitor_feature | 8 | `numerics_researcher` | 1.68× vs cpp — PH-5b |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | plan_debt | 5 | `plan_verifier`, `issue_planner` | Matrix `@` / SIMD matmul deferred |
| `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` | plan_debt | 5 | `plan_verifier`, `ci_maintainer` | Parallel compile + CI throughput |
| `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` | plan_debt | 7 | `swarm_observer` → `issue_planner` | Close on next missing_package sweep |
| `gap-line-profiler-001` | missing_package | 8 | `issue_planner` | HPC agent loop profiling — perf observability |

**Near-threshold (yellow, not red):** `num_eig_symmetric`, `num_root_newton`; integrators/CG/BFGS at ~1.18–1.20× cpp (`agent-briefing.json` → `ecosystem_audit.benchmarks`).

## Swarm dispatch order (post-audit)

1. `pr_merger` — lip#52 (merge-approved, gate-ready)  
2. `ci_maintainer` — 14 repos missing CI (unblocks perf CI gates)  
3. `bench_improver` + `numerics_researcher` — httpd wrk + near-threshold numerics  
4. `gap_explorer` — reconcile competitor_feature backlog after lic ingest PR merges  
5. `plan_verifier` — refresh snapshot; close stale `plan_pending` rows  

## Human-only

- lic master-plan partial phases (2e/2f/7d) — no auto-merge of provability shortcuts  
- CWE Top25 catalog backfill (19 rows) — `security_auditor`, human-gated  
- Consolidate benchmarks GPU chip picker PR stack (#147) — pick one winner among #400–#409  

## Evidence paths

- Registry: `lic/data/swarm-gap-registry/registry.yaml`  
- Apply log: `benchmarks/data/latest/swarm-gap-actions.json`  
- Scorecard: `benchmarks/data/latest/ecosystem-quality-report.json`  
- Briefing: `benchmarks/data/latest/agent-briefing.json`  
- Whitepaper: `lic/docs/research/swarm_coverage/performance/2026-06-07-whitepaper-1ebca9c6.md`  
