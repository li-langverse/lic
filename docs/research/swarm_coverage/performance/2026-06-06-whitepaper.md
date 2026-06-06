# Swarm gap orchestration — performance dimension

**Goal id:** `swarm_coverage`  
**Dimension:** `performance`  
**Agent:** `swarm_observer`  
**Worker:** `fd99f4e9`  
**Generated:** 2026-06-06T19:30Z  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`  
**north_star_fit:** ecosystem, ai — PH-5b (benchmark honesty), PH-7e (SIMD/parallel lowering)

---

## Abstract

This pass audits Li swarm health through a **performance lens**: benchmark posture, near-threshold regressions, and performance-class rows in the swarm gap registry. The ecosystem scorecard grades **D (60.9)** with `unattended_safe: false`. Gap ingest/apply remains blocked by missing PyYAML in the org-research worker image; a recurring SyntaxError in `swarm-gap-ingest.py` L229 was fixed locally. Performance work should route through research-lane agents (`bench_improver`, `numerics_researcher`) and patched backlogs — not retired systemd sim loops — respecting proof-before-perf.

---

## Benchmark posture (2026-06-06)

| Metric | Value | Evidence |
|--------|-------|----------|
| Green benchmarks | 39 | `agent-briefing.json` → `ecosystem_audit.benchmarks` |
| Near threshold (>1.0× cpp) | 5 | same |
| Unknown (no oracle) | 111 | same |
| Tier-1 red (registry) | 8 | `swarm-gap-actions.json` |
| Worst near-threshold | `simd_dot` 1.1279× | same |

### Near-threshold rows

| id | ratio_vs_cpp |
|----|--------------|
| simd_dot | 1.1279 |
| md_init_fcc_mb | 1.0199 |
| md_longrange_ewald | 1.0139 |
| md_integrator_verlet | 1.0129 |
| md_neighbor_cell_list | 1.0121 |

MD family rows are marginally above parity; **`simd_dot` is the priority perf handoff** — maps to patched backlog todo `sim-p1-num-dot-axpy` and PH-7e partial plan debt.

---

## Gap registry — performance class

Open gaps by kind (unchanged since 2026-05-31 apply):

| gap_kind | count |
|----------|-------|
| competitor_feature | 30 |
| plan_debt | 31 |
| missing_package | 3 |

**Performance-relevant competitor_feature examples:**

- `gap-benchmark-red-matmul-naive-tier1` (1.73× cpp)
- `gap-benchmark-red-num-gmres-tier1` (1.68× cpp)
- `gap-benchmark-red-num-opt-line-search-tier1` (2.00× cpp)
- `gap-hpc-kokkos-execution-memory-spaces`
- `gap-hpc-fftw-roofline-catalog-row`

**Plan debt (PH-7e):** `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` — deferred (no runner backlog mapping); requires proof track before perf codegen.

---

## Orchestration findings

1. **Gap pipeline broken** — PyYAML missing; ingest SyntaxError recurred until L229 fix.
2. **Observer blind** — no CP `latest-report.json` / `state.json`; grader `runs_sampled: 0`.
3. **CI blocks perf evidence** — 38 failed-CI PRs including benchmarks metrics refresh stack and GPU chip-picker duplicates (#400–409).
4. **111 unknown benchmarks** — performance coverage cannot be asserted until catalog stub-honest rows exist.

---

## Recommended handoffs

| Agent | Work item | north_star_fit |
|-------|-----------|------------------|
| `bench_improver` | tier-1 red microbenches + `simd_dot` | PH-5b, PH-7e |
| `numerics_researcher` | `md_sim_algorithms`, `sim-p1-num-dot-axpy` | PH-7e |
| `autoresearch` | novel simd_dot reduction strategies (proved) | PH-5b |
| `gap_explorer` | close unknown benchmark rows | PH-5b |
| `proof_gap_researcher` | Phase 7e partial before unsafe SIMD | PH-2e, PH-7e |
| `ci_maintainer` | unblock benchmarks CI for perf gates | ecosystem |

---

## Validity

| Grade | Rationale |
|-------|-----------|
| **B−** | Scorecard + briefing + gap actions on disk; gap ingest not re-run (PyYAML); snapshot stale 2026-05-30 |

---

## References

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r7-performance-handoffs.md`
- `/app/data/runs/swarm_observer-1780772999482.md`
- `li-cursor-agents/docs/ecosystem/research-verticals.md` — `md_sim_algorithms`, `numerics_sota`
