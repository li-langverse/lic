# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-30  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 69.8; `unattended_safe: false`) |
| Open gaps (post-cycle) | **53** — `competitor_feature: 30`, `plan_debt: 20`, `missing_package: 3` |
| `orch-r2` | **Completed** — vertical stubs + catalog gaps reconciled |
| Unattended? | **No** — mass historical `error` status in CP DB, 6/8 goal runners stopped |

Competitor-feature ingest is live: 30 open rows in registry (HPC libraries, tier-1 red benches, vertical stubs). Backlog apply patched **12** vertical stub todos across `sim-md-research-backlog.md` and `sim-algorithm-backlog.md`.

---

## Gap counts by `gap_kind` (open)

| `gap_kind` | Open | Primary discoverer | Backlog target |
|------------|-----:|--------------------|----------------|
| `competitor_feature` | 30 | `gap_explorer` | sim / sim-md-research backlogs; handoff numerics/bench |
| `plan_debt` | 20 | `plan_verifier`, snapshot | runner backlogs (sim, security-research, master-plan deferred) |
| `missing_package` | 3 | `gap_explorer` | `ecosystem-package-backlog.md` → `issue_planner` |

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

**Ingest deltas (2026-05-30T07:08Z):** `verticals_stubs: 0` (already in registry from lic `benchmarks/competitive/verticals.toml`), `competitor_catalog: 0` (explorer catalog current).

**Apply patches this cycle:**

| Target backlog | Rows patched |
|----------------|--------------|
| `docs/ecosystem/sim-md-research-backlog.md` | 9 vertical stubs (md_lennard_jones, drug_litl, bio_litl, scientific_viz, cinematic_*, mmo_shard, qm_dft) |
| `docs/ecosystem/sim-algorithm-backlog.md` | 3 PH-CAE stubs (pde_heat_2d, fea_linear_elasticity, cfd_lid_driven_cavity) — added `suggested_loop: sim` in registry |
| `docs/ecosystem/ecosystem-package-backlog.md` | pkg-line-profiler, pkg-std-summary, pkg-std-plot |
| `docs/ecosystem/sim-algorithm-backlog.md` | sim-p1-*, sim-p2-qm-dft-scf plan_debt |

**Deferred (no runner mapping):** master-plan `plan_debt` rows (8), swarm-observer orch-r3/r4, security-research sec-r1..r3.

---

## Competitor stub inventory (`verticals.toml`)

Source: `lic/benchmarks/competitive/verticals.toml` (15 verticals; 12 with `workload_class=stub`).

| Vertical id | workload_class | Registry gap | Backlog |
|-------------|----------------|--------------|---------|
| md_lennard_jones | stub | gap-vertical-stub-md-lennard-jones | sim-md-research |
| pde_heat_2d | stub | gap-vertical-stub-pde-heat-2d | sim |
| fea_linear_elasticity | stub | gap-vertical-stub-fea-linear-elasticity | sim |
| cfd_lid_driven_cavity | stub | gap-vertical-stub-cfd-lid-driven-cavity | sim |
| drug_litl, bio_litl, scientific_viz, cinematic_*, mmo_shard, qm_dft | stub | gap-vertical-stub-* | sim-md-research |
| gaming_rigid, robo_workspace, am_slicer | partial/v0 | not stub-ingested | — |

**Infra blocker:** `gap-infra-verticals-toml-missing-benchmarks-main` — `benchmarks/competitive/verticals.toml` not on benchmarks `main`; ingest falls back to lic copy. Route **docs_maintainer** / **gap_explorer** to land file on benchmarks main (no new systemd loop).

---

## Catalog / HPC competitor gaps (explorer)

Representative open rows (not vertical stubs):

- `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1` → **bench_improver**, **numerics_researcher** (PH-5b/7e)
- `gap-hpc-kokkos-execution-memory-spaces`, `gap-hpc-petsc-kokkos-implicit-pde` → **numerics_researcher**, **issue_planner**
- `gap-competitor-pure-li-ph7e-catalog` → codegen proof variants

Handoffs cite `north_star_fit`: proof → easy → fast; no gate weakening.

---

## Self-heal actions (programmatic observer)

Evidence: `control_plane_state.payload.observer` @ 2026-05-30T07:06:54Z

- `retry_counts: {}` — no auto-retries this tick (fresh supervisor wave)
- `stopped_agents: []` — no agents hard-stopped
- Gap ingest + apply ran pre-agent (supervisor preflight)

**Not auto-healed:** 7,189 `error` runs in last 48h (CP DB) — status reconciliation bug or batch kill; requires **li-cursor-agents** observer fix (see swarm_observer report).

---

## Human-only blockers

- **lic** dirty workspace on `perf/7e-matmul-blocked-codegen-bench-improver` — **workspace_sweeper** P0
- **org_agent_kit_audit** exit 1 (9 repos kit drift) — governance PRs, human review
- **132 branches** without open PR — **pr_branch_opener** (volume; not auto-merge)
- **trusted.lean** / provability governance — human-approved issues only

---

## Agent deliverable checklist

- [x] `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py`
- [x] Registry updated (`orch-r2` closed; sim routing for PH-CAE stubs)
- [x] Orchestrator note (this file)
- [x] `swarm-observer-plan-backlog.md` — orch-r2 → completed
- [ ] orch-r3 missing-package sweep (next iteration)
- [ ] orch-r4 ui_ux signals (next iteration)

**Systemd:** No new lic plan loops. Route via `research-goals.yaml` `swarm_coverage` handoff_to: `[gap_explorer, plan_verifier, issue_planner]`.
