# Orchestrator note — `orch-r10-performance-gap-handoffs`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `e7e99635`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai — performance dimension)  
**Work item:** Reconcile performance-related open gaps; route bench/httpd/sim handoffs via swarm goals (no new systemd loops)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **C** (72.6); `unattended_safe: false` |
| Performance lens | 2 yellow benches; 5 near-threshold integrators/optimizers; 8 tier-1 red gaps in registry |
| Gap pipeline | **Blocked** — ingest syntax fixed; PyYAML still missing in worker image |
| `orch-r3` / `orch-r4` | Still **open** in registry (snapshot stale @ 2026-05-30) |
| Unattended? | **No** — merge queue, CI gaps, and gap re-ingest require human or infra fix |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `/workspace/benchmarks/data/latest/ecosystem-audit.json`, `/workspace/lic/data/swarm-gap-registry/registry.yaml`.

---

## Performance gap taxonomy (open rows)

### `competitor_feature` — benchmark pressure (PH-5b / PH-7e)

| Registry id | Symptom | Ratio / signal | Handoff |
|-------------|---------|----------------|---------|
| `gap-benchmark-red-matmul-naive-tier1` | Tier-1 red | 1.73× vs cpp | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-gmres-tier1` | Tier-1 red | 1.68× vs cpp | `numerics_researcher` |
| `gap-benchmark-red-num-opt-line-search-tier1` | Tier-1 red | 2.00× vs cpp | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-integ-euler-tier1` | Tier-1 red | 1.40× vs cpp | `numerics_researcher`, `bench_improver` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | PH-7e partial | SIMD matmul deferred | `plan_verifier`, `issue_planner` |
| `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` | CI throughput | 8p partial | `plan_verifier`, `ci_maintainer` |

**Live audit yellow (not yet in registry red):** `num_eig_symmetric`, `num_root_newton` — route via `numerics_sota` goal → `numerics_researcher` + `bench_improver`.

**Near-threshold (1.18–1.20×):** `num_opt_bfgs`, `num_integ_semi_implicit`, `num_integ_euler`, `num_integ_rk4`, `num_cg` — monitor; no auto-dispatch until red.

### `plan_debt` — httpd / sim performance todos

| Registry id | Runner | Todo | Handoff |
|-------------|--------|------|---------|
| `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` | httpd | `gap-phase2-perf-wrk-soak` | `swarm_observer` → implement via `server_platform` research + human httpd gate |
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | sim | `sim-p1-num-dot-axpy` | `numerics_researcher` (`md_sim_algorithms`) |
| `gap-plan-pending-sim-sim-p1-md-neighbor-cell` | sim | `sim-p1-md-neighbor-cell` | `numerics_researcher` |
| `gap-plan-pending-sim-sim-p2-qm-dft-scf` | sim | `sim-p2-qm-dft-scf` | `numerics_researcher` (`chem_sim_algorithms`) |

Backlog patches from last successful apply @ 2026-05-31: `benchmarks/data/latest/swarm-gap-actions.json`.

### `missing_package` — profiling (performance observability)

| Registry id | Todo | Handoff |
|-------------|------|---------|
| `gap-line-profiler-001` | `pkg-line-profiler` | `issue_planner` |

Supports PH-8p wall-time SLO and agent-loop profiling; no product code in this pass.

---

## Swarm routing (async research lane — no new lic systemd loops)

| Agent / goal | Action |
|--------------|--------|
| `pr_merger` | Merge `lip#52` (deploy-pages bump) — gate ready |
| `ci_maintainer` | 14 repos missing CI (`org_ci_audit`); backoff on GH 403 |
| `bench_improver` | Tier-1 red rows + yellow `num_eig_symmetric` / `num_root_newton` |
| `numerics_researcher` | Goals `numerics_sota`, `md_sim_algorithms`, `physics_sim` — PH-5b/7e, proof-before-perf |
| `gap_explorer` | Reconcile 64 open gaps after PyYAML + ingest fix lands |
| `plan_verifier` | Refresh snapshot; close `orch-r3`, `orch-r4` registry rows |

---

## Control-plane fixes (this run)

1. **Remediated:** `swarm-gap-ingest.py:229` SyntaxError (missing paren on `BENCHMARKS_COMPETITIVE` fallback).
2. **Bootstrapped:** `/app/data/control-plane/state.json`, `latest-report.json` (observer persistence still needed in supervisor tick).
3. **Refreshed:** `ecosystem-quality-report.json` @ 2026-06-07T14:15:18Z (`LI_CURSOR_AGENTS_ROOT=/app`).

---

## Human-only blockers

- Governance PRs (`lic#1021`, `lic#1014`) — do not auto-merge.
- `trusted.lean` / provability gate changes — human-approved issues only.
- Bake `python3-yaml` (or vendored PyYAML) in org-research worker image.
- GitHub API rate limit during `org_ci_audit` — backoff / token rotation.

---

## Related

- Whitepaper staging: `lic/docs/research/swarm_coverage/performance/2026-06-07-whitepaper-e7e99635.md`
- Observer report: `/app/data/runs/swarm_observer-1780841017842.md`
- Prior performance pass: worker `7b620e59` @ 2026-06-07T12:30Z
