# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-29  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` registry rows; patch research/implement backlogs.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 64.8; `unattended_safe: false`) |
| Gap registry | **54 open** — 30 `competitor_feature`, 21 `plan_debt`, 3 `missing_package` |
| Vertical ingest | **12 stub rows** from `lic/benchmarks/competitive/verticals.toml` |
| Catalog ingest | **0 new** (existing rows retained from prior `gap_explorer` cycles) |
| Unattended? | **No** — 117 stuck SDK runs, 33% terminal error rate (sample), 6 goal runners stopped |

Competitor-feature orchestration is now wired: vertical stubs route to `sim-md-research-backlog.md` (MD/cinematic/bio) or `sim-algorithm-backlog.md` (CAE: heat/FEA/CFD).

---

## Gap counts by `gap_kind` (post orch-r2)

| `gap_kind` | Open | Primary discoverer | Backlog target |
|------------|-----:|--------------------|----------------|
| `competitor_feature` | 30 | `gap_explorer` | sim-md-research, sim-algorithm, handoffs to numerics/bench |
| `plan_debt` | 21 | `plan_verifier` | runner backlogs / deferred master-plan rows |
| `missing_package` | 3 | `gap_explorer` | `ecosystem-package-backlog.md` |
| `ui_ux` | 0 | — | orch-r4 pending |

---

## Scripts executed

```bash
cd benchmarks && python3 scripts/ecosystem-quality-grade.py
cd lic && python3 scripts/swarm-gap-ingest.py
cd lic && python3 scripts/swarm-gap-apply-actions.py
SWARM_OBSERVER_REQUIRE_NOTE=docs/ecosystem/orchestrator-notes/2026-05-29-orch-r2-competitor-stubs.md \
  ./scripts/swarm-observer-plan-gates.sh
```

**Evidence paths:**

- Registry: `lic/data/swarm-gap-registry/registry.yaml` (79 gaps total)
- Apply artifact: `benchmarks/data/latest/swarm-gap-actions.json`
- Vertical source: `lic/benchmarks/competitive/verticals.toml`
- Quality scorecard: `benchmarks/data/latest/ecosystem-quality-report.json`

---

## Backlog patches applied (competitor_feature)

| Target backlog | Rows appended | Gap ids (sample) |
|----------------|---------------|------------------|
| `docs/ecosystem/sim-md-research-backlog.md` | 9 | `gap-vertical-stub-md-lennard-jones`, `drug_litl`, `bio_litl`, `scientific_viz`, cinematic_*, `mmo_shard`, `qm_dft` |
| `docs/ecosystem/sim-algorithm-backlog.md` | 3 | `gap-vertical-stub-pde-heat-2d`, `fea_linear_elasticity`, `cfd_lid_driven_cavity` |

**Deferred competitor rows** (registry only — handoff via swarm goals, no backlog mapping):

- Tier-1 red benchmarks (`matmul_naive`, `num_gmres`, ML conv/MLP, etc.) → `numerics_researcher`, `bench_improver`
- HPC library gaps (Kokkos, PETSc, hypre, FFTW, RAJA, SUNDIALS, Chapel) → `numerics_researcher`, `issue_planner`
- Infra: `gap-infra-verticals-toml-missing-benchmarks-main` — `verticals.toml` on lic branch, not benchmarks main

**Systemd:** No new lic plan loops. Route via `li-cursor-agents/config/research-goals.yaml` (`swarm_coverage`, `numerics_research`).

---

## Registry reconciliation

- Closed `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs` with completion evidence.
- Added `suggested_loop: sim` on CAE vertical stubs so apply-actions patches `sim-algorithm-backlog.md`.
- `orch-r2-competitor-stubs` → **completed** in `swarm-observer-plan-backlog.md`.

---

## Self-heal actions (programmatic observer)

From `control_plane_state` (`updated_at` 2026-05-29T19:03Z):

- `observer.retry_counts`: `{}` (no auto-retries this tick)
- `stopped_agents`: `[]`
- Last scan: 2026-05-29T19:03:31Z

Programmatic observer has **not** cleared stuck SDK runs (117 `running` in local runs dir). Meta-audit recommends finalize-run sweep in `li-cursor-agents`.

---

## Human-only blockers

- Governance / provability PRs (`trusted.lean`, master-plan phase merges)
- `gap-infra-verticals-toml-missing-benchmarks-main` — merge `verticals.toml` to benchmarks main via human PR
- Preflight `--skip-slow` hides CI bug triage, plan audit, PR program (8 skipped scripts)

---

## Agent deliverable checklist

- [x] Ingest + apply-actions
- [x] Registry updated + orch-r2 closed
- [x] Orchestrator note (this file)
- [x] Run report under `data/runs/`
- [x] Gates OK
