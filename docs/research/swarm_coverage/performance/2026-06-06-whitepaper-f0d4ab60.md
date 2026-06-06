# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Worker:** `f0d4ab60`  
**Date:** 2026-06-06  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`  
**north_star_fit:** ecosystem, ai — PH-5b (numerics), PH-7e (SIMD/parallel); proof-before-perf

---

## Abstract

This pass audits swarm **performance** signals through the gap registry and ecosystem benchmark embed. The Li org shows **no tier-1 red** rows on the latest audit snapshot but **5 near-threshold** numerics (1.18–1.20× cpp) and **8 open tier-1-red-class** registry gaps awaiting ingest refresh. Gap apply remains blocked by missing PyYAML in the org-research worker, stalling backlog patches for `sim-p1-num-dot-axpy` and related PH-7e handoffs.

---

## Benchmark posture (evidence)

Source: `/workspace/benchmarks/data/latest/ecosystem-audit.json` (embed generated 2026-06-01).

| Class | Count | Examples |
|---|---|---|
| Green | 145 | — |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (≤1.20×) | 5 | `num_opt_bfgs` (1.20), integrators, `num_cg` |
| Red (tier-1) | 0 | — |

**Interpretation:** Org bench health is **recoverable** at tier-1 but SIMD/integrator microbenches need `bench_improver` attention before claiming PH-7e parity.

---

## Performance-relevant open gaps

Source: `/workspace/lic/data/swarm-gap-registry/registry.yaml` (64 open total).

### plan_debt (performance)

- `gap-plan-pending-sim-sim-p1-num-dot-axpy` — dot/axpy numerics for MD sim (PH-7e)
- `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` — SIMD matmul deferred

### competitor_feature (bench / HPC)

- Tier-1 red-class: `matmul_naive`, `num_gmres`, `num_opt_line_search`, integrators, physics stubs
- HPC libraries: Kokkos, PETSc, hypre, FFTW roofline, RAJA, SUNDIALS, OpenMP rubric

**Apply status:** Last successful apply 2026-05-31 (`swarm-gap-actions.json`); sim backlog patches pending re-apply.

---

## Orchestration findings

1. **Ingest syntax (L229):** Fixed — enables vertical stub ingest when `verticals.toml` present.
2. **PyYAML dependency:** Blocks full ingest/apply cycle — recurring failure across 20+ observer passes.
3. **Grader runs_dir:** Without `LI_CURSOR_AGENTS_ROOT=/app`, `runs_sampled=0` masks swarm execution health.
4. **Control-plane persistence:** Missing offline observer artifacts prevent auto-retry/healer dispatch.

---

## Recommended handoffs

| Priority | Agent | Target |
|---|---|---|
| P0 | `pr_merger` | lip#52 (deps bump — unblock CI infra) |
| P0 | `ci_maintainer` | 14 repos missing CI; fix benchmarks#400–409 stack |
| P1 | `bench_improver` | Near-threshold + tier-1 red registry rows |
| P1 | `numerics_researcher` | `md_sim_algorithms` / `sim-p1-num-dot-axpy` |
| P2 | `gap_explorer` | Refresh registry after PyYAML bake |

---

## Conclusion

Swarm **performance orchestration** is structurally sound (registry taxonomy, research-lane routing) but **operationally degraded** by environment gaps (PyYAML, CP persistence, stale gap apply). Unattended operation is **not safe** until ingest/apply runs green and failing PR CI is cleared. Proof-before-perf discipline is maintained — no recommendation to bypass Lean gates for SIMD work.

---

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780782000653.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r9-performance-f0d4ab60.md`
