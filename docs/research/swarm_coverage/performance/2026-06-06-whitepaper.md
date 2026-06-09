# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Date:** 2026-06-06  
**Worker:** `68380483`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`  
**north_star_fit:** ecosystem orchestration for PH-5b (HPC numerics) and PH-7e (SIMD/parallel lowering); proof-before-perf

---

## Abstract

This pass audits Li swarm health through a **performance lens**: benchmark posture, gap-registry routing for perf debt, and control-plane blockers that prevent unattended bench improvement. The ecosystem shows **zero tier-1 red rows** in the live audit but **`simd_dot` at 1.13× cpp** and five MD microbenches between 1.01–1.02×. Meanwhile, **109 benchmark catalog rows remain `unknown`**, and **62 open swarm gaps** include tier-1 red *registry* rows (`matmul_naive`, `num_gmres`, etc.) awaiting dispatch to `bench_improver` / `numerics_researcher`. Gap ingest/apply succeeded after repairing a recurring `swarm-gap-ingest.py` syntax defect.

---

## Benchmark posture (2026-06-06)

| Signal | Value | Source |
|--------|------:|--------|
| Green tier-1/2 rows | 39 | `ecosystem-audit.json` |
| Red rows (live audit) | 0 | same |
| Near threshold (>1.0×) | 5 | `simd_dot`, MD init/ewald/verlet/neighbor |
| Unknown catalog rows | 109 | same |
| Failed metrics PRs | 8+ | benchmarks #371–#376, #368 |

**Interpretation:** Live CI bench gates are green, but **coverage holes** (`unknown`) and **registry debt** (historical tier-1 red gaps) mean the swarm cannot honestly claim perf parity. Near-threshold `simd_dot` is the highest-risk regression without proactive `sim-p1-num-dot-axpy` work.

---

## Gap registry — performance taxonomy

| `gap_kind` | Count (open) | Performance role |
|------------|-------------:|------------------|
| `competitor_feature` | 30 | Tier-1 red bench rows, HPC library parity (Kokkos, PETSc, FFTW) |
| `plan_debt` | 31 | Master-plan PH-7e/8p partials; sim plan todos |
| `missing_package` | 1 | `li-line-profiler` — observability for perf agent loops |

**Apply pipeline:** `swarm-gap-apply-actions.py` patched sim and security backlogs; ph-db and studio-ui rows deferred (missing backlog paths).

---

## Orchestration findings

1. **Control-plane blind spot:** missing `data/control-plane/state.json` prevents retry budgeting and healer dispatch.
2. **Goal drift:** org-research lane ran repeated `swarm_observer` meta-audits while briefing prioritizes `ci_maintainer` and `pr_merger`.
3. **Infra recurrence:** PyYAML absent from runner image; ingest SyntaxError recurred until fixed — burns SDK minutes across workers.
4. **Proof-before-perf:** tier-1 red registry rows must not bypass `lic build` proof gates; route to research + bench_improver, not raw codegen shortcuts.

---

## Recommended dispatch order

1. `ci_maintainer` — unblock benchmarks#370 (li-parallel harness) and 6 repos missing CI  
2. `bench_improver` — `gap-benchmark-red-matmul-naive-tier1`, near-threshold `simd_dot`  
3. `numerics_researcher` — `md_sim_algorithms` goal + `sim-p1-md-neighbor-cell`  
4. `plan_verifier` — refresh goal-directed snapshot (stale 2026-05-30)  
5. `gap_explorer` — stub-honest registration for 109 unknown workloads  

---

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780739687193.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r7-performance-68380483.md`
