# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-29  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (`li-cursor-agents/config/research-goals.yaml`)  
**Branch:** `feat/world-studio-wave3-agentic` (lic working tree)  
**north_star_fit:** ecosystem + ai — gap registry drives numerics/bench handoffs without new systemd loops

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — ecosystem grade **D** (66.1), `unattended_safe: false` |
| Gap registry (post-ingest) | **79** gaps; **54 open** (`missing_package` 3, `plan_debt` 21, `competitor_feature` 30) |
| `competitor_feature` | **30 open** — catalog + vertical stubs + tier-1 red rows (ingest added 0 new this cycle; rows already present) |
| Vertical stub ingest | **0** from `verticals.toml` on disk — `benchmarks/competitive/verticals.toml` missing on benchmarks `main` |
| Unattended? | **No** — 106 runs stuck `running`, 21% terminal error rate, 36 failing PRs |

`orch-r2` reconciled registry ↔ apply pipeline: competitor rows hand off to `numerics_researcher` / `bench_improver`; vertical stubs patched into `sim-md-research-backlog.md`.

---

## Scripts executed

```bash
cd lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

**Ingest stdout:** `registry gaps: 79 ({'missing_package': 5, 'plan_debt': 44, 'competitor_feature': 30}) added={..., 'verticals_stubs': 0}`  
**Apply output:** `benchmarks/data/latest/swarm-gap-actions.json` — 18 backlog patches (3 package, 6 sim plan_debt, 9 vertical competitor append)

---

## Gap counts by `gap_kind` (open)

| `gap_kind` | Open | Primary discoverer | Orchestrator action |
|------------|-----:|--------------------|---------------------|
| `competitor_feature` | 30 | `gap_explorer` | Handoffs to research/implement goals; no lic product code |
| `plan_debt` | 21 | `plan_verifier`, snapshot | 6 sim backlogs patched; master_plan rows deferred |
| `missing_package` | 3 | `gap_explorer` | `ecosystem-package-backlog.md` todos pending |

---

## Competitor_feature highlights

| Gap id | Title | Handoff |
|--------|-------|---------|
| `gap-benchmark-red-matmul-naive-tier1` | matmul_naive 1.73× vs cpp | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-gmres-tier1` | num_gmres 1.68× vs cpp | `numerics_researcher` |
| `gap-infra-verticals-toml-missing-benchmarks-main` | verticals.toml missing on benchmarks main | `gap_explorer`, `docs_maintainer` |
| `gap-vertical-stub-md-lennard-jones` | MD vertical stub honesty | `numerics_researcher` → `sim-md-research-backlog.md` |
| `gap-hpc-kokkos-execution-memory-spaces` | Kokkos-class execution | `numerics_researcher`, `issue_planner` |

**Blocker:** `gap-infra-verticals-toml-missing-benchmarks-main` — merge or cherry-pick `benchmarks/competitive/verticals.toml` so future ingest cycles populate stub rows automatically.

---

## Backlog patches (apply-actions)

| Target | Action |
|--------|--------|
| `docs/ecosystem/sim-md-research-backlog.md` | Appended 9 `gap_orchestrator` vertical stub todos |
| `docs/ecosystem/sim-algorithm-backlog.md` | `sim-p1-*`, `sim-p2-qm-dft-scf` → pending |
| `docs/ecosystem/sim-md-research-backlog.md` | `md-r3-oracle-plan` → pending |
| `docs/ecosystem/ecosystem-package-backlog.md` | line_profiler, std.summary, std.plot → pending |

**Systemd:** None — swarm goals only (`research-goals.yaml` `swarm_coverage`, `stdlib_numerics`, etc.).

---

## Swarm routing (no new agent ids)

| Work | Route |
|------|-------|
| Tier-1 red microbenches | `bench_improver` + `numerics_researcher` via implement goals |
| Vertical stub research | `numerics_researcher` / `autoresearch` — sim-md backlog todos |
| verticals.toml on main | Human or `code_implementer` PR on **benchmarks** (not lic product) |
| Package seeds | `issue_planner` ← `ecosystem-package-backlog.md` |

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/agent-briefing.json`
- `li-cursor-agents/data/runs/swarm_observer-1780048585287.md`
