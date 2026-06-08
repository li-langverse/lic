# Orchestrator note — `orch-competitor-gaps` (worker `5e52da5c`)

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `competitor-gaps`  
**Work item:** Reconcile competitor_feature registry rows, ingest blockers, and swarm handoffs

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.3); `unattended_safe: false` |
| `competitor_feature` open | **30** rows (12 vertical stubs + HPC libs + historical tier-1 red + infra) |
| Live benchmark audit | **0 red**, 2 yellow (`num_eig_symmetric`, `num_root_newton`) — registry/audit drift |
| Gap ingest | **Blocked** — `PyYAML required`; last apply @ 2026-05-31 |
| Infra blocker | `gap-infra-verticals-toml-missing-benchmarks-main` — vertical honesty ingest returns 0 |
| Unattended? | **No** — ingest broken, lic#1504 CI fail, 12 repos missing CI |

---

## Competitor_feature taxonomy (open rows)

| Subclass | Count | Examples | Swarm route |
|----------|------:|----------|-------------|
| Vertical stubs (`verticals.toml`) | 12 | `md_lennard_jones`, `qm_dft`, `pde_heat_2d` | `numerics_researcher` via `md_sim_algorithms`, `chem_sim_algorithms`, `physics_sim` |
| HPC library parity | 8 | Kokkos, PETSc, hypre, FFTW, RAJA, SUNDIALS, OpenMP, Chapel | `numerics_researcher` / `scientific_distributed_computing` |
| Historical tier-1 red benches | 9 | `matmul_naive`, `num_gmres`, integrators | `bench_improver` — **close registry rows** when audit sustained green |
| PH-7e catalog | 1 | `gap-competitor-pure-li-ph7e-catalog` | `numerics_researcher` |
| Infra / ingest | 1 | `gap-infra-verticals-toml-missing-benchmarks-main` | `gap_explorer`, `docs_maintainer` |

Nine vertical stubs were patched to `sim-md-research-backlog.md` on 2026-05-31 (`swarm-gap-actions.json`). Four physics/CAE stubs (`pde_heat_2d`, `fea_linear_elasticity`, `cfd_lid_driven_cavity`, infra) lack backlog patches until ingest refresh.

---

## Ingest integrity

1. **Dependency** — PyYAML not in observer container; `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` exit 1.
2. **PR** — lic#1504 (ingest Path fallback) CI failing.
3. **Main branch** — `benchmarks/competitive/verticals.toml` not on main; ingest_verticals_stubs returns 0.

**Required sequence (post-merge lic#1504 + PyYAML in image):**

```bash
cd lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

---

## Plan_debt cross-links (competitor-adjacent)

| Registry id | Runner | Handoff |
|-------------|--------|---------|
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | sim | `numerics_researcher` / `md_sim_algorithms` |
| `gap-plan-pending-sim-sim-p2-qm-dft-scf` | sim | `numerics_researcher` / `chem_sim_algorithms` |
| `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` | swarm-observer | This pass — only `gap-line-profiler-001` open |
| `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` | swarm-observer | Defer to `gui_ux_tester` / `ui_ux_quality` goal |

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `gap_explorer` | 30 open competitor rows; verticals.toml infra; refresh explorer after ingest unblocked |
| `numerics_researcher` | HPC competitor gaps (Kokkos/PETSc/hypre); MD/QM vertical stubs |
| `bench_improver` | Historical tier-1 red registry rows vs green live audit |
| `docs_maintainer` | Ship `verticals.toml` on benchmarks main |
| `issue_planner` | `gap-line-profiler-001` missing_package |
| `ci_maintainer` | 12 repos missing CI; unblock lic#1504 CI |
| `pr_merger` | lip#52 merge-approved (after P0 ack) |

---

## Related artifacts

- Observer digest: `/app/data/runs/swarm_observer-1780962195694.md`
- Whitepaper: `/workspace/lic/docs/research/swarm_coverage/competitor-gaps/2026-06-08-whitepaper-5e52da5c.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- Actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
