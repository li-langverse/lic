# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-30  
**Agent:** `swarm_observer`  
**Branch:** `cursor/swarm-observer-plan-loop`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows; apply backlog patches.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **C**, 73.8; `unattended_safe: false`) |
| Competitor gaps | **30 open** `competitor_feature` rows in registry |
| Vertical stubs | **12** `workload_class = "stub"` in `lic/benchmarks/competitive/verticals.toml` |
| Ingest delta (this run) | `verticals_stubs: 0`, `competitor_catalog: 0` (rows already present) |
| Apply delta | **9** vertical-stub rows appended to `sim-md-research-backlog.md` |
| Unattended? | **No** — 65 open gaps, 6/9 goal runners stopped, 106/120 local runs stuck `running` |

`orch-r2` confirms the competitor_feature taxonomy is populated and backlogs are wired. Route follow-up via `numerics_researcher`, `bench_improver`, and `gap_explorer` — not new systemd plan loops.

---

## Sources ingested

| Source | Path | Rows |
|--------|------|-----:|
| Vertical stubs | `lic/benchmarks/competitive/verticals.toml` | 12 stub verticals |
| Explorer catalog | `benchmarks/data/latest/ecosystem-explorer.json` → `catalog.suggested_catalog_gaps` | 1 (pure_li PH-7e) |
| Ecosystem audit reds | `benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks.red` | 6 tier-1/2 bench ids |
| HPC library gaps | `ecosystem-explorer.json` → `hpc_libraries` missing/partial | Kokkos, PETSc, FFTW, hypre, RAJA, SUNDIALS, OpenMP, Chapel |

**Infra:** `gap-infra-verticals-toml-missing-benchmarks-main` stays open — ingest uses lic copy; landing on benchmarks main is a separate PR.

---

## Registry snapshot (post-ingest @ 2026-05-30T09:16Z)

| `gap_kind` | Open |
|------------|-----:|
| `competitor_feature` | 30 |
| `plan_debt` | 32 |
| `missing_package` | 3 |
| **Total** | **65** |

---

## Scripts executed

```bash
cd lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
cd ../benchmarks && python3 scripts/ecosystem-quality-grade.py
```

---

## Evidence paths

- Registry: `lic/data/swarm-gap-registry/registry.yaml`
- Apply digest: `benchmarks/data/latest/swarm-gap-actions.json`
- Scorecard: `benchmarks/data/latest/ecosystem-quality-report.json`
- Observer digest: `benchmarks/data/runs/swarm_observer-1780132501488.md`

---

## Next orchestrator todos

| id | Status on branch |
|----|------------------|
| `orch-r3-missing-package-sweep` | completed (prior iteration) |
| `orch-r4-ui-ux-signals` | completed (prior iteration) |
