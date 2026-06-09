# Orchestrator note — `orch-performance` (worker `abb73afe`)

**Date:** 2026-06-09  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Work item:** Reconcile performance gaps, benchmark posture, and gap-ingest blockers

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.3); `unattended_safe: false` |
| Live benchmarks | **0 red**, 2 yellow, 5 near-threshold (integrators/optimizers) |
| Gap ingest | **Blocked** — `PyYAML required`; actions @ 2026-05-31 |
| Registry | 64 open; 30 `competitor_feature` include stale tier-1 red rows |
| HTTPD perf | 2 pending wrk-soak todos; exit 124 in snapshot |
| Unattended? | **No** — ingest broken, CP state missing, lic#1504 CI red |

---

## Performance gap reconciliation

### Live benchmark posture

Source: `/workspace/benchmarks/data/latest/ecosystem-audit.json`

| Class | IDs |
|-------|-----|
| Yellow | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (>1.18×) | `num_opt_bfgs`, `num_integ_semi_implicit`, `num_integ_euler`, `num_integ_rk4`, `num_cg` |

**Action:** Dispatch `numerics_researcher` with PH-5b/PH-7e citations; proof-before-perf — no unproved SIMD shortcuts.

### Registry rows to refresh (ingest-dependent)

| Registry id | Kind | Route |
|-------------|------|-------|
| `gap-benchmark-red-matmul-naive-tier1` | competitor_feature | Close if audit sustained green; else `bench_improver` |
| `gap-benchmark-red-num-gmres-tier1` | competitor_feature | `numerics_researcher` |
| `gap-benchmark-red-num-integ-euler-tier1` | competitor_feature | Align with live near-threshold row |
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | plan_debt | `md_sim_algorithms` goal |
| `gap-plan-pending-httpd-*-perf-wrk*` | plan_debt | `server_platform` goal (retire httpd loop) |
| `gap-plan-debt-lic-master-plan-phase-7e-*` | plan_debt | `provability_holes` + `issue_planner` |
| `gap-plan-debt-lic-master-plan-phase-8p-*` | plan_debt | CI throughput — `ci_maintainer` cross-cut |
| `gap-line-profiler-001` | missing_package | `issue_planner` — perf observability for agent/HPC loops |

---

## Ingest blocker (unchanged)

```bash
swarm-gap-ingest: PyYAML required (pip install pyyaml)
swarm-gap-apply-actions: PyYAML required
```

**Action:** bake `python3-yaml` in org-research worker image. Merge **lic#1504** after CI green.

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `numerics_researcher` | Yellow + near-threshold numerics; PH-5b/7e registry rows |
| `bench_improver` | Near-threshold microbenches after proof gates |
| `pr_merger` | lip#52 merge-approved (observer does not merge) |
| `ci_maintainer` | 12 repos missing CI |
| `gap_explorer` | 64 open registry; ingest stale |
| `issue_planner` | `li-line-profiler` seed; close stale registry reds |

---

## Open orch todos (swarm-observer runner)

| Todo | Status | Next step |
|------|--------|-----------|
| `orch-r3-missing-package-sweep` | partial | Close `gap-line-profiler-001` via issue_planner |
| `orch-r4-ui-ux-signals` | open | studio GPU perf todos → `ui_ux_quality` |

---

## Related artifacts

- Observer digest: `/app/data/runs/swarm_observer-1780969395393.md`
- Whitepaper: `/workspace/lic/docs/research/swarm_coverage/performance/2026-06-09-whitepaper-abb73afe.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Dashboard pointer: `/app/data/goal-directed-sprints/org-lane-swarm-observer-last.json`
