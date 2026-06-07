# Orchestrator note — `orch-r5-performance`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `cfc23e5e`  
**Work item:** Reconcile performance-class gaps (benchmarks, PH-7e/PH-5b, httpd/sim perf plan debt)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 60.9; `unattended_safe: false`) |
| Open gaps | **62** (`competitor_feature` 30, `plan_debt` 29, `missing_package` 1) |
| Performance lens | 5 `near_threshold` tier-1 rows (1.18–1.20× cpp); 2 `yellow`; 0 `red` |
| Gap pipeline | **Blocked** — ingest SyntaxError L229; apply PyYAML missing |
| `orch-r5` | **Partial** — handoffs routed; live ingest/apply deferred until lic#952 + image bake |
| Unattended? | **No** — gap orchestration cannot self-heal without ingest/apply |

---

## Performance gap reconciliation

### Tier-1 benchmark pressure (briefing `ecosystem_audit.benchmarks`)

| Row | Class | ratio_vs_cpp | Registry gap | Handoff |
|-----|-------|-------------:|--------------|---------|
| `num_opt_bfgs` | near_threshold | 1.198 | — | `bench_improver` |
| `num_integ_semi_implicit` | near_threshold | 1.190 | `gap-benchmark-red-num-integ-euler-tier1` (related) | `numerics_researcher` |
| `num_integ_euler` | near_threshold | 1.186 | `gap-benchmark-red-num-integ-euler-tier1` | `numerics_researcher`, `bench_improver` |
| `num_integ_rk4` | near_threshold | 1.186 | — | `bench_improver` |
| `num_cg` | near_threshold | 1.185 | — | `bench_improver` |
| `num_eig_symmetric` | yellow | — | — | `bench_improver` |
| `num_root_newton` | yellow | — | — | `bench_improver` |

**North star:** proof-before-perf — route SIMD/codegen work to `numerics_researcher` (PH-7e) only after harness evidence; `bench_improver` owns near-threshold tier-1 tuning.

### High-priority `competitor_feature` (performance)

| Gap id | PH | Priority | Handoff |
|--------|-----|---------:|---------|
| `gap-benchmark-red-matmul-naive-tier1` | PH-7e | 8 | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-gmres-tier1` | PH-5b | 8 | `numerics_researcher` |
| `gap-benchmark-red-num-opt-line-search-tier1` | PH-5b | 8 | `numerics_researcher`, `bench_improver` |
| `gap-hpc-kokkos-execution-memory-spaces` | PH-7e | 7 | `numerics_researcher`, `issue_planner` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | — | 5 | `plan_verifier`, `issue_planner` |
| `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` | — | 5 | `plan_verifier`, `issue_planner` |

### `plan_debt` perf runners (open)

| Runner | Plan todo | Suggested loop | Handoff |
|--------|-----------|----------------|---------|
| `httpd` | `gap-phase2-perf-wrk-soak` | httpd | `code_implementer` via implement lane |
| `httpd` | `gap-phase2-streaming-wrk` | httpd | `code_implementer` |
| `sim` | `sim-p1-num-dot-axpy` | sim | `numerics_researcher` |
| `sim` | `sim-p1-md-neighbor-cell` | sim | `numerics_researcher` |
| `studio-ui-ux` | `studio-ux-16-palette-search-latency` | studio-ui-ux | `gui_ux_tester` |

### `missing_package` (HPC profiling)

| Gap id | Target | Handoff |
|--------|--------|---------|
| `gap-line-profiler-001` | `ecosystem-package-backlog.md` → `pkg-line-profiler` | `issue_planner` |

Closes `orch-r3-missing-package-sweep` when ingest runs and backlog patch confirms.

---

## Scripts attempted

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# → overall_score=60.9 grade=D unattended_safe=False

cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# → SyntaxError L229 (unterminated string)

cd /workspace/lic && python3 scripts/swarm-gap-apply-actions.py
# → PyYAML required
```

**Evidence:** `swarm-gap-actions.json` last applied 2026-05-31 (stale). Registry `updated_at` 2026-05-31.

---

## Handoffs enqueued (swarm goals — no new agent ids)

| Agent | Reason | north_star_fit |
|-------|--------|----------------|
| `bench_improver` | 5 near_threshold + 2 yellow tier-1 rows | PH-5b, PH-7e — fast after proof |
| `numerics_researcher` | matmul/gmres/integrator competitor gaps | PH-7e codegen, PH-5b solvers |
| `gap_explorer` | Re-run ingest after lic#952 merge | ecosystem, ai |
| `plan_verifier` | Refresh snapshot; close orch-r3/r4 rows | ecosystem |
| `issue_planner` | `pkg-line-profiler` + PH-7e master-plan items | provable, blazingly-fast |

---

## Control-plane fixes (file paths)

| Fix | Path |
|-----|------|
| Gap ingest env fallback | `lic/scripts/swarm-gap-ingest.py:229` (PR lic#952) |
| Bake PyYAML in worker | `li-cursor-agents/deploy/org-worker-entrypoint.sh` |
| Ecosystem grade runs_dir | `benchmarks/scripts/ecosystem-quality-grade.py` — use `/app/data/runs` fallback |
| Persist CP state offline | `li-cursor-agents/src/control-plane/build-report.ts` |

---

## Human-only blockers

- Merge **lic#952** (gap ingest fix) — governance on `lic` main
- **lip#52** merge-approved deploy-pages bump — human merge queue
- CWE Top25 catalog backfill (19 rows) — security policy
- `trusted.lean` / provability gate changes — never auto-merge

---

## Related artifacts

- Report: `/app/data/runs/swarm_observer-1780791904325.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Whitepaper: `/workspace/lic/docs/research/swarm_coverage/performance/2026-06-07-whitepaper-cfc23e5e.md`
