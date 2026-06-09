# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `abb73afe`  
**Run:** `swarm_observer-1780969395393`  
**Date:** 2026-06-09  
**north_star_fit:** ecosystem, ai — blazingly-fast pillar after proof (PH-7e, PH-5b, PH-8p)  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

---

## Abstract

This pass audits swarm gap orchestration through a **performance lens** on 2026-06-09. Live tier-1 benchmarks show **no red rows**, but **five near-threshold** numerics kernels and **two yellow** eigen/root solvers warrant continued `numerics_researcher` attention under proof-before-perf discipline. The swarm is **degraded** (grade D, 66.3): gap ingest remains blocked without PyYAML, the goal-directed snapshot is stale, and control-plane state is not persisted locally — performance backlogs cannot refresh unattended until ingest and observer infrastructure are repaired.

---

## 1. Live benchmark posture

**Source:** `/workspace/benchmarks/data/latest/ecosystem-audit.json` (benchmarks @ 2026-06-01)

| Class | Count | IDs |
|-------|-------|-----|
| Red (tier-1) | **0** | — |
| Yellow | **2** | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (>1.18× vs cpp) | **5** | `num_opt_bfgs` (1.20×), `num_integ_semi_implicit`, `num_integ_euler`, `num_integ_rk4`, `num_cg` (~1.19×) |
| Green | **145** | — |

**Implication:** Org numerics posture is healthy at tier-1 but **not fast-complete** — integrator and optimizer classes cluster just above the 1.18× watch line. Registry still lists historical tier-1 **red** competitor gaps; close on next successful ingest when audit confirms sustained green.

---

## 2. Performance plan_debt in registry

| Area | Open todos | Swarm goal (control plane) |
|------|------------|----------------------------|
| Sim numerics | `sim-p1-num-dot-axpy`, MD neighbor cell, QM DFT-SCF | `md_sim_algorithms`, `chem_sim_algorithms` |
| HTTPD | `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` (exit 124) | `server_platform` |
| Master plan | Phase 7e SIMD matmul, Phase 8p parallel compile/CI | `provability_holes` + `issue_planner` |
| Profiling package | `gap-line-profiler-001` | `issue_planner` → HPC loop observability |

Apply pipeline last patched sim rows @ 2026-05-31; httpd perf todos exist in snapshot but are absent from refreshed actions JSON because ingest did not run this cycle.

---

## 3. Competitor_feature pressure (HPC / codegen)

**Open in registry:** 30 rows. Performance-critical subset:

- **PH-7e:** `gap-competitor-pure-li-ph7e-catalog`, Kokkos, RAJA, OpenMP lowering rubric
- **PH-5b:** PETSc/hypre implicit PDE, GMRES, integrator classes, SUNDIALS stiff ODE
- **Infra:** `gap-infra-verticals-toml-missing-benchmarks-main` blocks vertical bench honesty ingest

**Routing:** `numerics_researcher` for sim/HPC verticals; `bench_improver` / `autoresearch` for catalog microbench improvements after proof gates. Do **not** spawn new `sim` systemd loops.

---

## 4. Gap-ingest and observer integrity

| Finding | Impact |
|---------|--------|
| PyYAML missing | Ingest/apply blocked; performance backlogs stale |
| CP `state.json` absent | Programmatic retry/healer state not observable |
| Grader `runs_sampled: 0` | `swarm_execution` dimension under-scored |
| lic#1504 CI fail | Ingest fallback PR blocked on main |

**Recommendations:**

1. Install `python3-yaml` in observer/briefing container
2. Merge lic#1504 when CI green
3. Fix grader `runs_dir` fallback to `/app/data/runs`
4. Auto-close registry tier-1 red rows when audit `benchmarks.red` is empty
5. Route httpd wrk soak via `server_platform` research goal

---

## 5. Swarm health summary

| Signal | Value |
|--------|-------|
| Scorecard | 66.3, grade D |
| `unattended_safe` | false |
| Open gaps | 64 |
| Goal runners stopped | 6/9 |
| Briefing top agents | `pr_merger`, `ci_maintainer`, `security_auditor` — aligned |
| `CURSOR_API_KEY` | set |

---

## Evidence index

| Artifact | Path |
|----------|------|
| Observer digest | `/app/data/runs/swarm_observer-1780969395393.md` |
| Orchestrator note | `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-09-orch-performance-abb73afe.md` |
| Ecosystem audit | `/workspace/benchmarks/data/latest/ecosystem-audit.json` |
| Quality scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap actions (stale) | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Goal-directed snapshot | `/workspace/lic/data/goal-directed-agents/snapshot.json` |
