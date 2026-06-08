# Orchestrator note — `orch-r15-performance-gaps`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `6e2efb9a`  
**north_star_fit:** ecosystem, ai — proof-before-perf (PH-7e, PH-5b)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **C**, 71.1; `unattended_safe: false`) |
| Performance bench | 0 red, 2 yellow, 5 near-threshold vs C++ |
| Gap pipeline | **Blocked** — `swarm-gap-ingest.py:229` SyntaxError; PyYAML missing for apply |
| Open gaps (total) | 64 (`competitor_feature` 30, `plan_debt` 31, `missing_package` 3) |
| Performance gaps | ~18 open rows (tier-1 red benches, HPC libs, PH-7e plan debt, sim/httpd perf todos) |

Programmatic prep **not confirmed** this cycle: ingest fails before registry refresh; apply requires PyYAML.

---

## Performance dimension signals

**Source:** `/workspace/benchmarks/data/latest/ecosystem-audit.json` (generated 2026-06-01)

| Class | IDs | Ratio vs C++ (where known) |
|-------|-----|----------------------------|
| Yellow | `num_eig_symmetric`, `num_root_newton` | >1.15× threshold |
| Near-limit | `num_opt_bfgs`, `num_integ_*`, `num_cg` | 1.18–1.20× |
| Green | 145 tier-1 rows | — |

**Registry performance handoffs (open, priority ≥7):**

| Gap id | Kind | Handoff |
|--------|------|---------|
| `gap-benchmark-red-matmul-naive-tier1` | competitor_feature | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-gmres-tier1` | competitor_feature | `numerics_researcher` |
| `gap-benchmark-red-num-opt-line-search-tier1` | competitor_feature | `bench_improver`, `numerics_researcher` |
| `gap-hpc-kokkos-execution-memory-spaces` | competitor_feature | `numerics_researcher`, `issue_planner` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | plan_debt | `plan_verifier`, `issue_planner` |
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | plan_debt | `swarm_observer` → `numerics_researcher` |
| `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` | plan_debt | implement lane / `code_implementer` |

**Snapshot stale:** `/workspace/lic/data/goal-directed-agents/snapshot.json` dated 2026-05-30 — httpd `gap-phase2-perf-wrk-soak` still `pending` in snapshot but registry rows partially deduped.

---

## Reconciliation actions (Mode B)

1. **Unblock ingest** — merge any open lic PR fixing line 229 (`Path(...)/ "verticals.toml"`); bake `python3-yaml` in org-research image.
2. **Re-run** `lic/scripts/swarm-gap-ingest.py` then `lic/scripts/swarm-gap-apply-actions.py` after merge.
3. **Route performance work** via research goals (no new systemd loops):
   - `numerics_sota` / `md_sim_algorithms` ← yellow eigen + Newton gaps
   - `scientific_distributed_computing` ← Kokkos/HPC gaps
   - implement lane ← httpd wrk soak todo
4. **Close orch-r3/r4** registry rows after ingest green + snapshot refresh.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780904354484.md`
