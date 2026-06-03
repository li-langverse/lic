# Orchestrator note — `swarm_coverage@performance`

**Date:** 2026-06-03  
**Agent:** `swarm_observer` (worker `1530aea0`)  
**Research goal:** `swarm_coverage`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Dimension:** performance (proof-before-perf; PH-7e / PH-5b bench posture)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **C** (70.3); `unattended_safe: false` |
| Benchmark tier-1 reds | **0** (improved vs registry stale rows) |
| Near-threshold (1.18–1.20× cpp) | 5 integrators/optimizers + 2 yellow eigen/root |
| Open gaps (performance-tagged) | ~25 of 64 open registry rows |
| Gap ingest | **Repaired** — `swarm-gap-ingest.py` L227–229 syntax + env default |
| Gap apply | **Ran** — `swarm-gap-apply-actions.py` @ 2026-06-03 (PyYAML installed in pod) |
| Control plane DB | **Unavailable** — MCP `ECONNREFUSED 127.0.0.1:54322` |

Programmatic prep this cycle:

```bash
cd /workspace/lic
LIC_ROOT=/workspace/lic BENCHMARKS_ROOT=/workspace/benchmarks python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
python3 /workspace/benchmarks/scripts/ecosystem-quality-grade.py  # overall 70.3, unattended_safe=false
```

Evidence: `benchmarks/data/latest/ecosystem-quality-report.json`, `benchmarks/data/latest/swarm-gap-actions.json`, `lic/data/swarm-gap-registry/registry.yaml`.

---

## Performance lens — benchmark posture

Source: `benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks` (generated 2026-06-01).

| Class | Bench ids | Ratio vs cpp | Route |
|-------|-----------|--------------|-------|
| **Yellow** | `num_eig_symmetric`, `num_root_newton` | >1.2× (tier policy) | `numerics_researcher` → `bench_improver` after proof review |
| **Near-threshold** | `num_opt_bfgs`, `num_integ_semi_implicit`, `num_integ_euler`, `num_integ_rk4`, `num_cg` | 1.18–1.20× | Monitor; no codegen shortcut — PH-7e proof path first |
| **Green** | 145 tier-1/2 rows | ≤1.2× | Maintain via `bench_improver` cadence |

Registry still lists tier-1 **red** competitor gaps (e.g. `gap-benchmark-red-matmul-naive-tier1`) — **stale vs live audit** (`red: []`). Close or refresh on next `gap_explorer` ingest after `verticals.toml` lands on `benchmarks/main`.

---

## Performance-related gap reconcile (open)

| `gap_kind` | Registry id | Handoff | Swarm route (no new systemd loops) |
|------------|-------------|---------|-------------------------------------|
| `plan_debt` | `gap-plan-pending-sim-sim-p1-num-dot-axpy` | `swarm_observer` | Patch applied → `sim-algorithm-backlog.md`; **`numerics_researcher`** / `md_sim_algorithms` goal |
| `plan_debt` | `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | `plan_verifier`, `issue_planner` | Master-plan partial — **`proof_gap_researcher`** before SIMD matmul |
| `plan_debt` | `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` | `plan_verifier`, `issue_planner` | CI throughput — **`ci_maintainer`** + compiler team issue |
| `plan_debt` | `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `swarm_observer` | **`gui_ux_tester`** / `ui_ux_quality` goal; lic#575 |
| `competitor_feature` | `gap-hpc-kokkos-execution-memory-spaces` | `numerics_researcher`, `issue_planner` | PH-7e — research lane `scientific_distributed_computing` |
| `competitor_feature` | `gap-hpc-fftw-roofline-catalog-row` | `bench_improver`, `gap_explorer` | Roofline catalog row in benchmarks |
| `competitor_feature` | `gap-infra-verticals-toml-missing-benchmarks-main` | `gap_explorer`, `docs_maintainer` | Blocks vertical stub ingest — file exists in tree at `benchmarks/workloads/competitive/verticals.toml`, not on main |
| `missing_package` | `gap-line-profiler-001` | `issue_planner` | HPC agent loop profiling — **`stdlib_researcher`** scoping only |

**Closed this cycle (registry unchanged status):** httpd perf wrk/soak plan_debt rows remain closed from prior orch-r1 dedupe.

---

## Swarm routing (performance)

| Agent / goal | Action |
|--------------|--------|
| `bench_improver` | Near-threshold numerics (`num_opt_bfgs`, RK4/Euler/CG) — evidence-first, no unproved `@` |
| `numerics_researcher` | `sim-p1-num-dot-axpy`, Kokkos/PETSc competitor gaps — cite PH-7e |
| `gap_explorer` | Refresh stale red bench rows; merge `verticals.toml` to benchmarks main |
| `plan_verifier` | Re-run plan audit preflight (skipped `--skip-slow`) — reduces plan_debt noise |
| `ci_maintainer` | Briefing P0: 1 repo missing CI — blocks perf CI signal |
| `swarm_observer` | Next `swarm_coverage` cadence after ingest stable on org-research image |

Do **not** recommend `install-goal-plan-loop-systemd.sh` — use async swarm research/implement lanes per `docs/ecosystem/swarm-architecture.md`.

---

## Human-only blockers

- Merge wave: 61 open PRs, 7 failing CI (including benchmarks#307–309 scorecard refresh)
- GitHub API rate limit on `org_ci_audit` (HTTP 403)
- Supabase / control-plane DB offline in Job pods
- Governance: master-plan partial phases (7e, 8p) — no auto-merge codegen without proof

---

## Related

- Prior notes: `2026-05-31-orch-r3-missing-package-sweep.md`
- Whitepaper stub (this run): included in `li-cursor-agents/data/runs/swarm_observer-1780529387496.md` — publish to `research-findings/whitepapers/2026-06/swarm_coverage/performance/` when repo mounted
