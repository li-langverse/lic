# Orchestrator note — `orch-performance` (worker `b027373c`)

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Work item:** Reconcile performance-related plan_debt, benchmark posture, and gap-ingest blockers

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.3); `unattended_safe: false` |
| Benchmark audit | **0 red**, 2 yellow, 5 near-threshold (integrators/optimizers ~1.18–1.20× vs cpp) |
| Gap ingest | **Blocked** — `PyYAML required`; actions stale @ 2026-05-31 |
| Performance plan_debt | httpd wrk soak (2 todos), sim dot/axpy + MD/QM (3 todos), Phase 7e/8p partial |
| Unattended? | **No** — ingest broken, 12 repos missing CI, failed PR CI on lic#1504 |

---

## Performance plan_debt reconciliation

| Registry id | Backlog / runner | Apply patch (2026-05-31) | Handoff |
|-------------|------------------|---------------------------|---------|
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | `sim-algorithm-backlog.md` | pending | `numerics_researcher` / `md_sim_algorithms` |
| `gap-plan-pending-sim-sim-p1-md-neighbor-cell` | sim backlog | pending | `numerics_researcher` |
| `gap-plan-pending-sim-sim-p2-qm-dft-scf` | sim backlog | pending | `numerics_researcher` / `chem_sim_algorithms` |
| httpd `gap-phase2-perf-wrk-soak` | httpd plan (snapshot pending) | not in actions JSON | `goal_researcher` / `server_platform` |
| httpd `gap-phase2-streaming-wrk` | httpd plan (snapshot pending) | not in actions JSON | `goal_researcher` / `server_platform` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | master plan partial | deferred | `plan_verifier`, `numerics_researcher` (PH-7e) |
| `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` | master plan partial | deferred | `issue_planner`, `ci_maintainer` |

Evidence:

- `/workspace/benchmarks/data/latest/ecosystem-audit.json` — `benchmarks.yellow`, `near_threshold`
- `/workspace/lic/data/goal-directed-agents/snapshot.json` — httpd `plan_pending`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json` — sim patches @ 2026-05-31

---

## Competitor_feature / bench gaps (performance lens)

| Priority | Gap id | Title | Route |
|----------|--------|-------|-------|
| P8 | `gap-benchmark-red-matmul-naive-tier1` | matmul_naive 1.73× vs cpp | `bench_improver` (registry; audit currently 0 red) |
| P8 | `gap-benchmark-red-num-opt-line-search-tier1` | line_search 2.00× vs cpp | `bench_improver` |
| P7 | `gap-hpc-kokkos-execution-memory-spaces` | Kokkos execution model | `numerics_researcher` / `scientific_distributed_computing` |
| P6 | `gap-competitor-pure-li-ph7e-catalog` | PH-7e codegen catalog variants | `numerics_researcher` |
| P5 | `gap-infra-verticals-toml-missing-benchmarks-main` | blocks vertical bench ingest | `gap_explorer`, `docs_maintainer` |

**Live audit (2026-06-08):** tier-1 **red count = 0**; yellow = `num_eig_symmetric`, `num_root_newton`. Registry retains historical red rows for orchestration until closed after bench green.

---

## Ingest blocker

1. **Dependency** — `PyYAML required`; not installed in observer container (`pip`/`python3-yaml` unavailable).
2. **Infra** — `gap-infra-verticals-toml-missing-benchmarks-main` still open.
3. **PR** — lic#1504 (ingest fallback fix) CI failing.

**Action:** Land lic#1504 after CI green; add `python3-yaml` to briefing CI image; re-run:

```bash
cd lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `numerics_researcher` | Yellow + near-threshold benches; sim MD/QM plan_debt (`md_sim_algorithms`, `chem_sim_algorithms`) |
| `bench_improver` | Historical tier-1 red rows in registry; autoresearch lane for novel methods |
| `goal_researcher` | httpd perf soak via `server_platform` goal |
| `gap_explorer` | 62 open registry rows; ingest stale |
| `ci_maintainer` | 12 repos missing CI; Phase 8p CI throughput |
| `pr_merger` | lip#52 merge-approved (after P0 perf/security acknowledged) |

---

## Related artifacts

- Observer digest: `/app/data/runs/swarm_observer-1780957694205.md`
- Whitepaper: `/workspace/lic/docs/research/swarm_coverage/performance/2026-06-08-whitepaper-b027373c.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
