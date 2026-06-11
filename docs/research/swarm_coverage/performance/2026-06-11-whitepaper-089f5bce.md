# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `089f5bce`  
**Date:** 2026-06-11  
**north_star_fit:** ecosystem, ai — proof → easy → fast  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

---

## Abstract

This pass audits swarm health through a **performance lens**: benchmark posture, performance-related gap registry rows, and orchestration blockers that prevent unattended gap closure. The Li tier-1 matrix shows **no red rows** (145 green, 2 yellow, 5 near-threshold), but the swarm remains **degraded (conditional)** because control-plane telemetry is incomplete, PyYAML was absent until an ephemeral apt fix, and briefing-recommended leaf agents diverge from the scorecard.

---

## Benchmark posture (2026-06-11)

Source: `/workspace/benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks`

| Class | Count | Examples |
|-------|-------|----------|
| Green | 145 | — |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (≈1.18–1.20×) | 5 | BFGS, semi-implicit, Euler, RK4, CG |
| Red | 0 | — |

**Interpretation:** Performance work should focus on **near-threshold** explicit integrators and optimizers (low-risk SIMD/horner paths under PH-7e) and **yellow** dense linear algebra — not on reviving stale tier-1 red registry rows that no longer match the live audit.

---

## Gap registry — performance-relevant open rows

Source: `/workspace/lic/data/swarm-gap-registry/registry.yaml` (62 open @ `00:05:46Z`)

### Competitor / benchmark (`competitor_feature`)

- Stale tier-1 red: `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1`, integrator reds — **close when audit stays green**
- HPC library gaps: Kokkos, PETSc, FFTW roofline, hypre — research via `numerics_sota` / `scientific_distributed_computing`
- PH-7e catalog: `gap-competitor-pure-li-ph7e-catalog` → `bench_improver`

### Plan debt (`plan_debt`)

- `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` — partial 1d dot; matrix `@` deferred (proof gate)
- `gap-plan-pending-sim-sim-p1-num-dot-axpy` — sim backlog patched; handoff research lane
- httpd wrk: `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` — pending; exit 124 history

### Missing package

- `gap-line-profiler-001` — line-level profiling for HPC agent loops; seed only; **`issue_planner`**

---

## Orchestration blockers (performance of the swarm itself)

| Blocker | Impact on perf lane | Remediation |
|---------|---------------------|-------------|
| PyYAML missing (cold start) | Gap registry stale → wrong bench handoffs | Bake in org-research image |
| CP state ENOENT | Observer cannot auto-retry `bench_improver` | Supervisor persist each tick |
| Snapshot stale (2026-05-30) | httpd wrk debt invisible to heap | Refresh snapshot job |
| Briefing drift | `gap_explorer` not dispatched | Align heap with scorecard |

---

## Recommendations

1. **P0:** Bake PyYAML in worker image; re-run ingest/apply on every cycle without apt.
2. **P1:** Dispatch `bench_improver` on 5 near-threshold rows after PH-7e proof check.
3. **P1:** Route httpd wrk soak via `server_platform` goal — proof-before-perf (timing gates).
4. **P2:** Seed `li-line-profiler` via `issue_planner` for agent-loop profiling.
5. **P2:** Auto-close stale tier-1 red registry rows in `swarm-gap-ingest.py`.

---

## Evidence

- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Gap actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Observer report: `/app/data/runs/swarm_observer-1781134901690.md`
- Orchestrator note: `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-11-orch-performance-089f5bce.md`
