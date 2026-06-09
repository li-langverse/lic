# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Worker:** `de2e933b`  
**Date:** 2026-06-08  
**north_star_fit:** ecosystem, ai — performance pillar (3) only after mathematical provability  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

---

## Abstract

This pass audits Li numerics and swarm-registry performance signals under the `swarm_coverage` research goal. Tier-1 benchmark posture improved to **zero red rows** since the May scorecard, but **two yellow** and **five near-threshold** microbenches remain. Sixty-four open swarm gaps include eight historical tier-1 red `competitor_feature` registry rows and httpd/sim plan-debt perf todos. Gap ingest was blocked by a SyntaxError (fixed) and missing PyYAML in the observer container.

---

## Benchmark evidence

Source: `/workspace/benchmarks/data/latest/ecosystem-audit.json` (`generated_at` 2026-06-01).

| Class | Count | Examples |
|-------|------:|----------|
| Green | 145 | — |
| Red | 0 | — |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (≥1.18× cpp) | 5 | `num_opt_bfgs` (1.20), integrators, `num_cg` |

**Interpretation:** No tier-1 regression alarms in live audit, but yellow symmetric eigen and Newton root finders need `numerics_researcher` triage before `bench_improver` targets SIMD/parallel lowering (PH-7e).

---

## Registry performance gaps

Source: `/workspace/lic/data/swarm-gap-registry/registry.yaml` + `/workspace/benchmarks/data/latest/swarm-gap-actions.json`.

| `gap_kind` | Perf-relevant open | Primary handoff |
|------------|-------------------:|-----------------|
| `competitor_feature` | 30 (incl. 8 tier-1 red catalog) | `bench_improver`, `numerics_researcher` |
| `plan_debt` | 31 (httpd wrk soak, sim dot/axpy, 7e/8p) | `plan_verifier`, `issue_planner` |
| `missing_package` | 1 (`line_profiler`) | `issue_planner` |

---

## Orchestration recommendations

1. **Proof-before-perf:** Route yellow/near-threshold work through `numerics_sota` research then `bench_improver` implement goal — no `unsafe` or unproved fast paths.
2. **Refresh gap apply pipeline:** Ship PyYAML in preflight image; rerun ingest+apply after lic ingest fix.
3. **httpd perf debt:** `gap-phase2-perf-wrk-soak` and `gap-phase2-streaming-wrk` — handoff to `server_platform` goal, not new systemd loop.
4. **Scorecard runs path:** Point `ecosystem-quality-grade.py` at `/app/data/runs` when sibling agents repo absent — restores swarm_execution scoring.

---

## Related artifacts

- Meta audit: `/app/data/runs/swarm_observer-1780916054236.md`
- Orchestrator note: `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r19-performance-gap-orchestration.md`
- Ecosystem grade: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
