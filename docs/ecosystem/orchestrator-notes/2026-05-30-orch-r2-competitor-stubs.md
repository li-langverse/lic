# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-30  
**Agent:** `swarm_observer`  
**Branch:** `cursor/swarm-observer-plan-loop`  
**Research goal:** `swarm_coverage`  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows; patch sim/httpd backlogs.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 69.8; `unattended_safe: false`) |
| Goal-directed loops | **6/8 stopped** — snapshot `agents_live: 0` |
| Gap registry | **54 open** (79 total) — 30 `competitor_feature`, 21 `plan_debt`, 3 `missing_package` |
| Unattended? | **No** — GitHub GraphQL rate limit, SDK error burst (5502/24h), stale control-plane health report |

`orch-r2-competitor-stubs` reconciled: 30 `competitor_feature` rows present; vertical stub backlogs patched via apply-actions (idempotent re-run 2026-05-30T04:16Z).

---

## Gap counts by `gap_kind` (post-ingest)

| `gap_kind` | Open | Primary discoverer | Backlog target |
|------------|-----:|--------------------|----------------|
| `competitor_feature` | 30 | `gap_explorer` | `sim-algorithm-backlog.md`, `sim-md-research-backlog.md` |
| `plan_debt` | 21 | `plan_verifier`, snapshot | runner backlogs (deferred master-plan rows) |
| `missing_package` | 3 | `gap_explorer` | `ecosystem-package-backlog.md` |
| `ui_ux` | 0 open on plan-loop | `gui_ux_tester` | studio plan (orch-r4 closed) |

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
# benchmarks: python3 scripts/ecosystem-quality-grade.py
SWARM_OBSERVER_REQUIRE_NOTE=docs/ecosystem/orchestrator-notes/2026-05-30-orch-r2-competitor-stubs.md \
  ./scripts/swarm-observer-plan-gates.sh
```

**Ingest signals (2026-05-30T04:16Z):** `verticals_stubs=0`, `competitor_catalog=0` — rows already in registry; ingest idempotent.

**Source paths:**

- `lic/benchmarks/competitive/verticals.toml` — 12 stub verticals (`workload_class=stub`)
- `benchmarks/data/latest/ecosystem-explorer.json` — HPC + catalog gaps
- Evidence: `benchmarks/data/latest/swarm-gap-actions.json`

---

## Backlog patches applied (competitor_feature)

| Gap id | Patch target |
|--------|--------------|
| `gap-vertical-stub-md-lennard-jones` | `sim-md-research-backlog.md` |
| `gap-vertical-stub-pde-heat-2d` | `sim-algorithm-backlog.md` |
| `gap-vertical-stub-fea-linear-elasticity` | `sim-algorithm-backlog.md` |
| `gap-vertical-stub-cfd-lid-driven-cavity` | `sim-algorithm-backlog.md` |
| `gap-vertical-stub-drug-litl` … `qm-dft` | `sim-md-research-backlog.md` (9 rows) |
| HPC/benchmark red rows | Handoff → `numerics_researcher`, `bench_improver` |

**Open infra gap:** `gap-infra-verticals-toml-missing-benchmarks-main` — land `verticals.toml` on benchmarks main.

**Systemd:** No new lic plan loops. Route via `research-goals.yaml` `swarm_coverage` → `gap_explorer`, `plan_verifier`, `issue_planner`.

---

## Registry reconciliation

- Closed: `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs`
- `swarm-observer-plan-backlog.md`: `orch-r2-competitor-stubs` → `completed`

---

## Self-heal actions (programmatic observer)

- `observer.retry_counts`: `{}` — no auto-retries
- `stopped_agents`: `[]`
- `control_plane_reports.swarm_health.healthy`: **true** (stale 2026-05-25) — meta observer invoked correctly

---

## Recommended control-plane fixes

| Path | Fix |
|------|-----|
| `li-cursor-agents/src/observer/` | `swarm_degraded` on GraphQL 403 or SDK error burst |
| `li-cursor-agents/src/backends/cursor-sdk-backend.js` | Orphan `running` → `incomplete` timeout |
| `benchmarks/scripts/pr-program*.py` | REST fallback when GraphQL exhausted |
| `benchmarks/scripts/workspace-dirty-sweep.py` | Skip push when rate-limited |

---

## Human-only blockers

- GitHub GraphQL quota reset
- Governance PR merges
- benchmarks main: `competitive/verticals.toml`

---

## Agent deliverable checklist

- [x] Ingest + apply-actions
- [x] Registry reconciled; orch-r2 closed
- [x] Orchestrator note + reports
- [x] Gates OK

**north_star_fit:** ecosystem + ai — competitor parity registry feeds numerics/sim research without weakening proof gates (PH-5b, PH-7e).
