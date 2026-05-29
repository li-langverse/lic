# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-29  
**Agent:** `swarm_observer`  
**Run:** `swarm_observer-1780086771776`  
**Research goal:** `swarm_coverage`  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows; patch sim/httpd backlogs.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **C**, 76.3; `unattended_safe: true` with caveats) |
| orch-r2 | **Complete** — 30 `competitor_feature` rows reconciled; 12 vertical stub todos patched to research backlogs |
| verticals.toml | Present at `lic/benchmarks/competitive/verticals.toml` (14 `workload_class=stub` rows) |
| Gap registry open | **53** after closing infra + orch-r2 plan_debt rows |
| Unattended? | **Partial** — programmatic heal active; 6 goal runners stopped, 108 SDK runs stuck `running` |

Programmatic prep **confirmed**: `swarm-gap-ingest.py` (idempotent, 0 new stubs) + `swarm-gap-apply-actions.py` (live).

---

## Gap counts by `gap_kind` (post-orch-r2)

| `gap_kind` | Open | Closed this cycle | Primary discoverer |
|------------|-----:|------------------:|--------------------|
| `competitor_feature` | 29 | 1 (`gap-infra-verticals-toml-missing-benchmarks-main`) | `gap_explorer` |
| `plan_debt` | 20 | 1 (`orch-r2-competitor-stubs`) | `plan_verifier`, snapshot |
| `missing_package` | 3 | 0 | `gap_explorer` |
| `ui_ux` | 6 | 0 (orch-r4 prior) | `gui_ux_tester` |

**Ingest delta:** `verticals_stubs: 0`, `competitor_catalog: 0` — registry already held 30 competitor rows from prior orch-r2 iterations; this pass fixed backlog routing for PDE/FEA/CFD stubs.

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
cd ../benchmarks && python3 scripts/ecosystem-quality-grade.py
```

---

## Backlog patches applied

| Target backlog | Vertical / gap todos |
|----------------|---------------------|
| `docs/ecosystem/sim-md-research-backlog.md` | 9 stubs (md_lennard_jones, drug_litl, bio_litl, scientific_viz, cinematic_*, mmo_shard, qm_dft) |
| `docs/ecosystem/sim-algorithm-backlog.md` | 3 stubs (pde_heat_2d, fea_linear_elasticity, cfd_lid_driven_cavity) — added `suggested_loop: sim` in registry |
| `docs/ecosystem/ecosystem-package-backlog.md` | 3 × `pkg-*` (line_profiler, std.summary, std.plot) |
| `docs/ecosystem/sim-algorithm-backlog.md` | 3 × sim plan_debt (dot-axpy, neighbor-cell, qm-dft-scf) |

### Registry fixes (orchestration)

- Added `suggested_loop: sim` to PDE/FEA/CFD vertical stubs so `apply-actions` patches `sim-algorithm-backlog.md`
- Closed `gap-infra-verticals-toml-missing-benchmarks-main` — file exists on branch; merge to main is human-only
- Closed `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs`

---

## Handoffs (swarm goals — no new systemd loops)

| Gap cluster | Route to | Goal / agent |
|-------------|----------|--------------|
| Tier-1 red benches (matmul, gmres, ML) | `bench_improver`, `numerics_researcher` | implement-goals numerics lane |
| HPC library parity (Kokkos, PETSc, hypre) | `numerics_researcher`, `issue_planner` | research-goals numerics |
| Vertical stubs (MD/PDE/CFD) | sim / sim-md-research backlogs | goal-directed sim loops via control plane |
| Missing std modules | `issue_planner`, `package_architect` | ecosystem-package-backlog |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — retired per `docs/ecosystem/swarm-architecture.md`.

---

## Evidence paths

- `lic/benchmarks/competitive/verticals.toml`
- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `lic/docs/ecosystem/swarm-observer-plan-backlog.md` (orch-r2 → completed)

---

## Next orchestrator todos

| ID | Action |
|----|--------|
| `orch-r3-missing-package-sweep` | Confirm pkg-* pending; handoff `issue_planner` |
| `orch-r4-ui-ux-signals` | Already ingested 2026-05-29 earlier run; mark backlog completed |
| Observer | Finalize stuck `running` SDK runs; refresh stale `control_plane_reports` |
