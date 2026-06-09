# Orchestrator note — `orch-r21-performance-gap-orchestration`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance` (worker `95ea3c7d`)  
**Work item:** Reconcile performance-related open gaps; near-threshold bench dispatch; unblock gap apply pipeline

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (65.8)**; `unattended_safe: false` |
| Gap apply | **Blocked** — PyYAML missing; ingest syntax fixed |
| Perf signal | 2 yellow + 5 near-threshold numerics; 8 tier-1 red rows in registry |
| Control plane | `state.json` / `latest-report.json` **missing** in li-cursor-agents data dir |
| Unattended? | **No** — gap refresh + observer persistence required |

---

## Performance gap reconciliation

### Near-threshold benches (watch → handoff before red)

| Bench id | ratio_vs_cpp | PH | Handoff |
|----------|--------------|-----|---------|
| `num_opt_bfgs` | 1.20 | PH-7e | `bench_improver` |
| `num_integ_semi_implicit` | 1.19 | PH-5b | `numerics_researcher` |
| `num_integ_euler` | 1.19 | PH-5b | `numerics_researcher` |
| `num_integ_rk4` | 1.19 | PH-5b | `numerics_researcher` |
| `num_cg` | 1.18 | PH-5b | `numerics_researcher` |

Yellow: `num_eig_symmetric`, `num_root_newton` — same lane; proof-before-perf (no unsafe shortcuts).

Evidence: `/workspace/benchmarks/data/latest/ecosystem-audit.json` → `benchmarks`.

### Registry tier-1 red rows (competitor_feature)

Open in `registry.yaml`; backlog patches from 2026-05-31 apply still valid:

- `gap-benchmark-red-matmul-naive-tier1` (1.73×) → `bench_improver`, `numerics_researcher`
- `gap-benchmark-red-num-gmres-tier1` (1.68×) → `numerics_researcher`
- `gap-benchmark-red-num-integ-euler-tier1`, `num_integ_verlet`, `num_opt_line_search`, `cloth_swing`, `orbit_two_body`, `schrodinger_1d_barrier` → numerics research lane

Research goals (no new registry ids): `numerics_sota`, `md_sim_algorithms`, `physics_sim`.

### Plan_debt perf todos

| Gap id | Runner | Patch target | Swarm route |
|--------|--------|--------------|-------------|
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | sim | `sim-algorithm-backlog.md` | `numerics_researcher` / `md_sim_algorithms` |
| `gap-plan-pending-httpd-*-perf-wrk-soak` | httpd | httpd plan | `server_platform` goal + `bug_fixer` for CI |
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | studio-ui-ux | studio plan | `gui_ux_tester` / `ui_ux_quality` |
| `gap-plan-debt-lic-master-plan-phase-7e-*` | master_plan | — | `proof_gap_researcher` then perf (PH-7e) |
| `gap-plan-debt-lic-master-plan-phase-8p-*` | master_plan | — | `ci_maintainer` parallel compile throughput |

---

## Pipeline status

```bash
# Fixed this run (syntax):
/workspace/lic/scripts/swarm-gap-ingest.py  # line 229 Path() fix

# Still blocked:
python3 scripts/swarm-gap-ingest.py    # PyYAML required
python3 scripts/swarm-gap-apply-actions.py
```

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `bench_improver` | Near-threshold + tier-1 red numerics |
| `numerics_researcher` | Integrator / linalg / HPC competitor gaps |
| `gap_explorer` | `gap_pressure` score 60; 64 open gaps |
| `ci_maintainer` | 12 repos missing CI; org_ci_audit failed |
| `issue_planner` | `pkg-line-profiler` seed (profiling for perf diagnosis) |

---

## Related artifacts

- Run digest: `/app/data/runs/swarm_observer-1780941261022.md`
- Whitepaper: `docs/research/swarm_coverage/performance/2026-06-08-whitepaper-95ea3c7d.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
