# Orchestrator note — performance gap orchestration (`025ca089`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Worker:** `025ca089`  
**Run:** `1781211102593`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (conditional)** — grade **C** (76.1); `unattended_safe: true` |
| Gap prep | **Blocked** — PyYAML missing; last apply @ `00:05:46Z` |
| Open gaps | **62** (1 missing_package, 31 plan_debt, 30 competitor_feature) |
| Performance audit | **0 red**; **2 yellow**; **5 near-threshold** (~1.18–1.20× cpp) |
| Control plane | **Missing** `state.json` / `latest-report.json` |
| Unattended? | **Conditional** — execution clean; gap refresh + CP persist needed |

---

## Performance reconciliation (proof → easy → fast)

North-star order respected: no unproved SIMD shortcuts recommended. Near-threshold numerics route to `bench_improver` only after proof gates hold on touched kernels.

| Bench id | Ratio vs cpp | Status | Route |
|----------|--------------|--------|-------|
| `num_opt_bfgs` | 1.1978 | near-threshold | `bench_improver` → `numerics_sota` |
| `num_integ_semi_implicit` | 1.19 | near-threshold | `bench_improver` |
| `num_integ_euler` | 1.1863 | near-threshold | `bench_improver` (close stale registry red) |
| `num_integ_rk4` | 1.1863 | near-threshold | `bench_improver` |
| `num_cg` | 1.1848 | near-threshold | `bench_improver` |
| `num_eig_symmetric` | yellow | `numerics_researcher` (PH-7e linalg) |
| `num_root_newton` | yellow | `numerics_researcher` (PH-5b) |

**Stale registry:** `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1`, `gap-benchmark-red-num-opt-line-search-tier1`, and siblings remain `open` while `ecosystem-audit.benchmarks.red` is `[]`. Ingest should auto-close on next successful run.

**httpd perf plan debt:** `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` — route via `server_platform` research goal; do not install new lic systemd loops.

**PH-7e:** `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` — partial 1d `float` `@`; matrix `@` deferred until proof surface complete.

---

## Gap orchestration (Mode B)

```bash
# This run (BLOCKED):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py      # FAIL: PyYAML required
python3 scripts/swarm-gap-apply-actions.py

# Last successful cycle @ 00:05:46Z:
# benchmarks/data/latest/swarm-gap-actions.json (19 backlog patches)
```

| `gap_kind` | Open | Patched last cycle | Handoff |
|------------|------|--------------------|---------|
| `missing_package` | 1 (`li-line-profiler`) | `pkg-line-profiler` pending | `issue_planner` |
| `plan_debt` | 31 | sim/security backlogs | `plan_verifier`, `implementation_gaps` |
| `competitor_feature` | 30 | vertical stubs → sim-md | `gap_explorer`, `bench_improver` |

**`orch-r3`:** route `gap-line-profiler-001` via `issue_planner`; sweep HPC package gaps on `gap_explorer` cadence.

**`orch-r4`:** route via `ui_ux_quality` → `gui_ux_tester`; no new agent ids.

**Goal drift:** briefing heap = `ci_maintainer` only; scorecard adds `gap_explorer`, `plan_verifier`, and performance needs `bench_improver`. Merge recommendation sources before dispatch.

---

## Control-plane fixes (orchestration only)

1. Bake `python3-yaml` in worker image.
2. Bootstrap `data/control-plane/state.json` on supervisor start.
3. Auto-close tier-1 red gap rows when audit `red: []`.
4. Briefing merge: include scorecard agents + `bench_improver` when `near_threshold` non-empty.
5. Wire `orch-r3`/`orch-r4` backlog mappings in apply script.

---

## Evidence

- Scorecard: `benchmarks/data/latest/ecosystem-quality-report.json`
- Briefing: `benchmarks/data/latest/agent-briefing.json`
- Registry: `lic/data/swarm-gap-registry/registry.yaml`
- Actions: `benchmarks/data/latest/swarm-gap-actions.json`
- Run report: `/app/data/runs/swarm_observer-1781211102593.md`

**Next dispatch:** `gap_explorer` → `bench_improver` → `plan_verifier` → `ci_maintainer` → `security_auditor`
