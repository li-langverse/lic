# Orchestrator note — `orch-r6-performance-gap-handoffs`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `ded8e427`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** performance  
**Work item:** Reconcile performance-linked open gaps; route bench/sim/httpd handoffs

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (60.9)**; `unattended_safe: false` |
| Gap registry | **64 open** — unchanged since 2026-05-31 (ingest/apply blocked) |
| Bench posture | **0 red**, **2 yellow**, **5 near-threshold** (>1.18× cpp) |
| Ingest prep | Syntax fix applied locally; **PyYAML missing** in worker |
| Unattended? | **No** — gap pipeline + CP persistence + CI rate limits |

---

## Performance gap reconciliation

### Tier-1 bench signals (evidence: `benchmarks/data/latest/ecosystem-audit.json`)

| Signal | IDs | Action |
|--------|-----|--------|
| Yellow | `num_eig_symmetric`, `num_root_newton` | `numerics_researcher` → PH-5b research goal |
| Near threshold (1.18–1.20×) | `num_opt_bfgs`, `num_integ_*`, `num_cg` | `bench_improver` watch list; no red escalation |
| Registry red-class gaps | `matmul_naive`, `num_gmres`, `num_opt_line_search`, etc. | Handoff `bench_improver` + `numerics_researcher` |

### Plan debt — performance runners

| Registry id | Runner | plan_todo | Handoff |
|-------------|--------|-----------|---------|
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | sim | `sim-p1-num-dot-axpy` | `numerics_researcher` |
| `gap-plan-pending-sim-sim-p1-md-neighbor-cell` | sim | `sim-p1-md-neighbor-cell` | `numerics_researcher` |
| `gap-plan-pending-sim-sim-p2-qm-dft-scf` | sim | `sim-p2-qm-dft-scf` | `numerics_researcher` |
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | studio-ui-ux | `studio-ux-16-palette-search-latency` | `gui_ux_tester` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | master_plan | Phase 7e SIMD | `plan_verifier` → `issue_planner` |
| `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` | master_plan | Phase 8p CI throughput | `plan_verifier` |

**httpd snapshot** (stale 2026-05-30): `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` still pending — route to httpd research after proof gates; do **not** weaken perf bars.

### Competitor / HPC gaps (PH-7e, PH-5b)

Priority 7–8 rows: Kokkos, PETSc, matmul, GMRES, line_search, OpenMP lowering rubric — all route via existing agents (`numerics_researcher`, `bench_improver`, `issue_planner`). No new registry ids.

---

## Control-plane actions (no product code)

1. **Merge** ingest Path fallback (`lic/scripts/swarm-gap-ingest.py` L229).
2. **Bake PyYAML** in org-research worker — unblocks ingest + apply.
3. **Align runs_dir** in `ecosystem-quality-grade.py` to `/app/data/runs`.
4. **Update `config/research-goals.yaml`** — ensure `numerics_sota` / `physics_sim` cadence covers near-threshold bench ids (via `npm run research-goals:sync` on li-cursor-agents).

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780806307240.md`

---

## Next handoffs

| To | Reason |
|----|--------|
| `pr_merger` | lip#52 gate-ready |
| `bench_improver` | near-threshold + registry red-class bench gaps |
| `numerics_researcher` | PH-7e SIMD, sim plan todos, HPC competitor gaps |
| `gap_explorer` | after PyYAML — refresh registry + verticals ingest |
| `plan_verifier` | refresh snapshot; close orch-r3/r4 |

Do **not** recommend `install-goal-plan-loop-systemd.sh` — retired loops live on agents control plane per `docs/ecosystem/swarm-architecture.md`.
