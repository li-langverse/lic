# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `cf791dc1`  
**Date:** 2026-06-12  
**north_star_fit:** ecosystem, ai — proof → easy → fast  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

---

## Abstract

This pass audits swarm health through a **performance lens**: benchmark posture, performance-related gap registry rows, and orchestration blockers that prevent unattended gap closure. The Li tier-1 matrix shows **no red rows** (153 green, 2 yellow, 5 near-threshold), but the swarm remains **degraded (conditional)** because control-plane telemetry is incomplete, PyYAML blocks live gap ingest, and briefing-recommended leaf agents diverge from the scorecard — leaving near-threshold integrators and yellow linear algebra undispatched.

---

## Benchmark posture (2026-06-12)

Source: `/workspace/benchmarks/data/latest/ecosystem-audit.json` → `benchmarks` (`generated_at: 2026-06-12T00:51Z`)

| Class | Count | Examples |
|-------|-------|----------|
| Green | 153 | — |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (≈1.18–1.20×) | 5 | BFGS, semi-implicit, Euler, RK4, CG |
| Red | 0 | — |
| Unknown | 28 | tier-5 / GPU / registry rows — harness refresh needed |

**Interpretation:** Performance work should focus on **near-threshold** explicit integrators and optimizers (low-risk SIMD/horner paths under PH-7e) and **yellow** dense linear algebra — not on reviving stale tier-1 red registry rows that no longer match the live audit.

Pillar order respected: all near-threshold work routes through `bench_improver` only after PH-7e proof gates; no `unsafe` or unproved shortcuts.

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
- httpd wrk: `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` — pending; exit 124 history on snapshot

### Missing package

- `gap-line-profiler-001` — line-level profiling for HPC agent loops; seed only; **`issue_planner`**

---

## Orchestration blockers (performance of the swarm itself)

| Blocker | Impact on perf lane | Remediation |
|---------|---------------------|-------------|
| PyYAML missing (cold start) | Gap registry stale → wrong bench handoffs | Bake in org-research image |
| CP state ENOENT | Observer cannot auto-retry `bench_improver` | Supervisor persist each tick |
| Briefing heap drift | Near-threshold benches not dispatched | Merge scorecard recommendations |
| Stale registry reds | Noise hides real perf gaps | Auto-close in ingest |
| lic#1473 CI fail | Performance orchestration fixes cannot merge | Human triage |

---

## Recommendations

1. Dispatch `bench_improver` for 5 near-threshold rows after PH-7e proof check.
2. Route yellow eigen/Newton to `numerics_researcher` with PH-7e linalg context.
3. Close stale tier-1 red gap rows in next successful ingest cycle.
4. Fix lic#1473 CI so swarm-gap orchestration fixes can merge.
5. Do **not** recommend retired lic systemd loops — use async swarm goals.

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781225499946.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-12-orch-performance-cf791dc1.md`
