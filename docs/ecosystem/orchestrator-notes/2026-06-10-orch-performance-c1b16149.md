# Orchestrator note — performance gap orchestration (`c1b16149`)

**Date:** 2026-06-10  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Worker:** `c1b16149`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (conditional)** — grade **C** (75.6); `unattended_safe: true` |
| Gap prep | **Blocked** — PyYAML missing; last apply @ 03:54Z |
| Open gaps | **62** (1 missing_package, 31 plan_debt, 30 competitor_feature) |
| Performance audit | **0 red** tier-1; **2 yellow**; **5 near-threshold** (~1.18–1.20× cpp) |
| Unattended? | **Conditional** — CP mirrors missing; briefing leaf agents not dispatched |

---

## Performance reconciliation (proof → easy → fast)

Pillar order enforced: no perf shortcuts before proof. Near-threshold benches are **eligible** for `bench_improver` only where PH-7e codegen paths are already proved.

| Bench id | Ratio vs cpp | Status | Route |
|----------|--------------|--------|-------|
| `num_opt_bfgs` | 1.1978 | near-threshold | `bench_improver` → `numerics_sota` |
| `num_integ_semi_implicit` | 1.19 | near-threshold | `bench_improver` |
| `num_integ_euler` | 1.1863 | near-threshold | `bench_improver` |
| `num_integ_rk4` | 1.1863 | near-threshold | `bench_improver` |
| `num_cg` | 1.1848 | near-threshold | `bench_improver` |
| `num_eig_symmetric` | yellow | `numerics_researcher` (PH-7e linalg) |
| `num_root_newton` | yellow | `numerics_researcher` |

**Stale registry rows:** `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1`, and 6+ sibling tier-1 reds remain `open` while `ecosystem-audit.benchmarks.red` is `[]`. Next ingest should auto-close when audit green persists.

**httpd perf plan debt:** `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` pending on `httpd` runner (exit 124 history). Route via `server_platform` research goal — not a new lic systemd loop.

**PH-7e plan debt:** `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` — partial 1d `float` `@`; matrix `@` deferred until proof gate clears.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

| `gap_kind` | Open | Patched @ 03:54Z | Handoff |
|------------|------|------------------|---------|
| `missing_package` | 1 (`li-line-profiler`) | `pkg-line-profiler` pending | `issue_planner` |
| `plan_debt` | 31 | sim/security/httpd backlogs re-confirmed | `plan_verifier`, `implementation_gaps` |
| `competitor_feature` | 30 | vertical stubs → sim-md backlogs | `gap_explorer`, `bench_improver` |

**Blocker:** `swarm-gap-ingest: PyYAML required` — apt `python3-yaml` not available in pod; bake into org-research image.

---

## Control-plane observations

| Gap | Risk | Fix owner |
|-----|------|-----------|
| No CP disk mirrors | Observer state opaque across Job restarts | `li-cursor-agents` supervisor |
| PyYAML absent | Stale gap registry → wrong handoffs | deploy image |
| Briefing vs scorecard agent drift | `ci_maintainer`/`security_auditor` in heap; `gap_explorer` missing | `benchmarks` briefing script |
| `LI_CURSOR_AGENTS_ENABLED=0` | Agent deliverable gate skipped | env default in briefing build |

---

## Handoffs (swarm goals — no new agent ids)

| Target | Work | north_star_fit |
|--------|------|----------------|
| `bench_improver` | Near-threshold tier-1/2 numerics (5 rows) | PH-7e, provable |
| `numerics_researcher` | Yellow eigen/Newton; PH-7e SIMD matmul debt | PH-5b, PH-7e |
| `gap_explorer` | Re-ingest; close stale red rows; verticals.toml on main | ecosystem |
| `issue_planner` | `li-line-profiler` package seed | PH-7e profiling |
| `plan_verifier` | Master-plan partial phases (2e/2f/7d/7e) | provable |
| `goal_researcher` | httpd wrk soak via `server_platform` | PH-H httpd |
| `pr_merger` | lip#52 (merge-approved) | platform |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json` → `benchmarks`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/goal-directed-agents/snapshot.json`
- `/app/data/runs/swarm_observer-1781081318349.md`
