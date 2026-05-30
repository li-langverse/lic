# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-30  
**Agent:** `swarm_observer`  
**Branch:** `cursor/swarm-observer-plan-loop`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows; patch research/implement backlogs.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **C**, 71.3; `unattended_safe: false`) |
| Gap registry | **65 open** (30 `competitor_feature`, 32 `plan_debt`, 3 `missing_package`) |
| `orch-r2` | **Completed** — 30 competitor rows tracked; 12 vertical stubs patched to backlogs |
| Unattended? | **No** — 33% error rate in last 45 terminal runs; 6/9 goal runners stopped |

Competitor gap orchestration reconciles Layer B honesty (`verticals.toml` `workload_class=stub`) with swarm registry + sim research backlogs. Catalog/HPC/benchmark-red rows remain open for `numerics_researcher` / `bench_improver` handoffs.

---

## Gap counts by `gap_kind` (post orch-r2)

| `gap_kind` | Open | Patched this cycle | Primary handoff |
|------------|-----:|-------------------:|-----------------|
| `competitor_feature` | 30 | 12 vertical stubs → backlogs | `numerics_researcher`, `bench_improver` |
| `plan_debt` | 32 | orch-r2 closed | `plan_verifier`, goal-directed loops |
| `missing_package` | 3 | orch-r3 prior | `issue_planner` |
| `ui_ux` | 0 | — | `orch-r4` next |

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
cd ../benchmarks && python3 scripts/ecosystem-quality-grade.py
```

**Ingest signals:** `verticals_stubs: 0` new (all stubs already in registry); `competitor_catalog: 0` new. Source: `lic/benchmarks/competitive/verticals.toml` (17 verticals; 13 stub/partial honesty rows).

---

## Vertical stub → backlog routing

| Registry id | Vertical | Backlog | Todo id |
|-------------|----------|---------|---------|
| `gap-vertical-stub-md-lennard-jones` | `md_lennard_jones` | `sim-md-research-backlog.md` | `gap-competitor-gap-vertical-stub-md-lennard-jones` |
| `gap-vertical-stub-drug-litl` … `qm-dft` | 8 cinematic/bio/mmo stubs | `sim-md-research-backlog.md` | `gap-competitor-gap-vertical-stub-*` |
| `gap-vertical-stub-pde-heat-2d` | PH-CAE heat | `sim-algorithm-backlog.md` | `gap-competitor-gap-vertical-stub-pde-heat-2d` |
| `gap-vertical-stub-fea-linear-elasticity` | PH-CAE FEA | `sim-algorithm-backlog.md` | `gap-competitor-gap-vertical-stub-fea-linear-elasticity` |
| `gap-vertical-stub-cfd-lid-driven-cavity` | PH-CAE CFD | `sim-algorithm-backlog.md` | `gap-competitor-gap-vertical-stub-cfd-lid-driven-cavity` |

**Deferred (registry only):** HPC library rows, tier-1 benchmark-red rows, `gap-infra-verticals-toml-missing-benchmarks-main`.

---

## Self-heal actions (control plane)

- Gap ingest + apply @ 2026-05-30T10:36Z — 23 backlog patches (idempotent).
- Programmatic observer: `retry_counts: {}`; remediations: `implementation_gaps`, `proof_gap_researcher` goal-align retry.
- Registry: `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs` → **closed**.

No product code in lic.

---

## Agent deliverable checklist

- [x] Ingest + apply-actions confirmed
- [x] 30 `competitor_feature` rows reconciled; 12 vertical stubs in backlogs
- [x] `orch-r2-competitor-stubs` closed in registry + plan backlog
- [x] Digest → `benchmarks/data/runs/swarm_observer-1780137256044.md`
