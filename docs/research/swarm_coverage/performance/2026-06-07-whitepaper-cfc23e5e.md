# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `cfc23e5e`  
**Date:** 2026-06-07  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai; performance lens maps to PH-5b (numerics) and PH-7e (codegen/SIMD) per pillar order proof → easy → fast.

---

## Abstract

This pass audits the Li agent swarm through a **performance** lens: tier-1 benchmark posture, open `competitor_feature` registry rows tied to PH-5b/PH-7e, and `plan_debt` items on httpd/sim runners. Ecosystem quality is grade **D** (60.9) with `unattended_safe: false`. The gap ingest/apply pipeline is blocked, preventing automated backlog patches for sim-algo and httpd perf todos. Five numerics micro-benches sit in `near_threshold` (1.18–1.20× cpp); two are `yellow`. Handoffs route proof-respecting perf work to `bench_improver` and `numerics_researcher` without disabling provability gates.

---

## Method

1. Regenerated `ecosystem-quality-report.json` via `benchmarks/scripts/ecosystem-quality-grade.py`.
2. Read `agent-briefing.json` `ecosystem_audit.benchmarks` for red/yellow/near_threshold.
3. Reconciled `lic/data/swarm-gap-registry/registry.yaml` (62 open) against `swarm-gap-actions.json`.
4. Attempted programmatic prep: `swarm-gap-ingest.py`, `swarm-gap-apply-actions.py`.
5. Compared `recommended_agents` (briefing vs scorecard) for goal-orientation drift.
6. Bootstrapped missing control-plane artifacts (`state.json`, `latest-report.json`).

---

## Performance findings

### Benchmark matrix (2026-06-01 harness)

| Class | Count | Examples |
|-------|------:|----------|
| green | 145 | — |
| red | 0 | — |
| yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| near_threshold (≥1.18×) | 5 | `num_opt_bfgs`, integrators, `num_cg` |

**Interpretation:** No tier-1 red rows in current audit snapshot, but five rows are within 2% of the 1.2× advisory bar — proactive `bench_improver` dispatch prevents regression to red.

### Registry performance pressure

| `gap_kind` | Open | Performance-relevant subset |
|------------|-----:|------------------------------|
| `competitor_feature` | 30 | 8 tier-1 red stubs + 6 HPC library gaps (Kokkos, PETSc, FFTW) |
| `plan_debt` | 29 | httpd wrk-soak, sim dot/axpy, phase 7e/8p partial |
| `missing_package` | 1 | `li-line-profiler` (HPC agent loop profiling) |

### Swarm execution health

- `runs_sampled: 0` in scorecard (path mismatch: `/workspace/li-cursor-agents/data/runs` vs `/app/data/runs`).
- Current cycle: single `swarm_observer` run in progress; no terminal error streaks.
- Prior dimension runs (security 2026-06-07, ux/api-coverage 2026-06-06) completed successfully.

---

## Gap orchestration status

| Step | Status | Blocker |
|------|--------|---------|
| Ingest | **Failed** | `SyntaxError` L229 `swarm-gap-ingest.py` |
| Apply | **Failed** | `ModuleNotFoundError: yaml` |
| Registry reconcile | **Manual** | This note + handoffs |
| Backlog patches | **Stale** | Last apply 2026-05-31 |

**Remediation:** Merge lic#952; bake `python3-yaml` in org-research worker image.

---

## Recommendations

1. **P0:** Unblock gap pipeline (lic#952 + PyYAML image bake).
2. **P1:** Dispatch `bench_improver` on near_threshold + yellow rows before they flip red.
3. **P1:** Route PH-7e competitor gaps (`matmul_naive`, Kokkos) to `numerics_researcher` with proof harness evidence.
4. **P2:** Close httpd `gap-phase2-perf-wrk-soak` via implement lane (not retired systemd loop).
5. **P2:** Fix `ecosystem-quality-grade.py` runs_dir to sample `/app/data/runs`.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r5-performance-cfc23e5e.md`
- `/app/data/control-plane/latest-report.json`
- `/app/data/control-plane/state.json`

---

## Publish target

`research-findings/whitepapers/2026-06/swarm_coverage/performance/2026-06-07-whitepaper-cfc23e5e.md` (deferred — repo not mounted in worker).
