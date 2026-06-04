# Swarm coverage — performance dimension

**Goal:** `swarm_coverage` · **Dimension:** performance · **Worker:** `792ea6a5`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/` (staging in `lic` until publish repo mounted)

## north_star_fit

Ecosystem orchestration for **proof → easy → fast**: performance gaps must not bypass PH-7e proof gates. Domains: ecosystem, ai. PH ids: **PH-7e** (SIMD/matmul), **PH-5b** (numerics/solvers), **PH-H** (httpd wrk soak).

## Thesis

The swarm can route performance debt through the **gap registry + apply pipeline**, but **measurement honesty** and **control-plane run telemetry** are the bottlenecks — not missing agent ids.

## Findings

1. **Scorecard:** grade D, `unattended_safe: false` — [`ecosystem-quality-report.json`](../../../../benchmarks/data/latest/ecosystem-quality-report.json).
2. **Benchmark posture split:** `ecosystem-audit.json` reports `red: []` while registry retains tier-1 `gap-benchmark-red-*` rows — reconcile after catalog PRs merge.
3. **Unknown catalog dominance:** briefing lists 140+ `unknown` benchmarks — perf regression detection is effectively off.
4. **httpd soak debt:** `gap-phase2-perf-wrk-soak` pending in goal-directed snapshot — blocks PH-H perf claims.
5. **Plan debt 7e:** master-plan Phase 7e partial (1d dot only; SIMD matmul deferred) — tracked as `plan_debt`, not `competitor_feature` alone.
6. **Gap ingest fragility:** supervisor tick failed on `BENCHMARKS_COMPETITIVE` KeyError until default path fix (this run).
7. **Swarm execution blind spot:** grader `runs_sampled: 0` because `runs_dir` points outside Job mount.

## Recommendations

| Priority | Action | Owner agent |
|----------|--------|-------------|
| P0 | Merge catalog honesty PRs; refresh tier-1 bench rows | `ci_maintainer`, human review |
| P0 | Fix `runs_dir` in quality grader | `ecosystem_grader` / benchmarks script |
| P1 | Route 9 tier-1 red registry rows → bench improvement | `bench_improver`, `numerics_researcher` |
| P1 | Close httpd wrk soak plan todo | `code_implementer` |
| P2 | Bake PyYAML + ingest env in org-research image | `li-cursor-agents` infra |

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780578997929.md`

---

_Staged for research-findings publish · 2026-06-04_
