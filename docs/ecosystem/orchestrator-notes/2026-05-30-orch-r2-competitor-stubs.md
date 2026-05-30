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
| Gap registry | **57 open** — 30 `competitor_feature`, 18 `plan_debt`, 3 `missing_package`, 6 `ui_ux` |
| Unattended? | **No** — GitHub GraphQL rate limit, 117 stuck SDK runs, error streaks |

`orch-r2-competitor-stubs` reconciled: 30 `competitor_feature` rows present; vertical stub backlogs patched via apply-actions.

---

## Gap counts by `gap_kind` (post-ingest)

| `gap_kind` | Open | Primary discoverer | Backlog target |
|------------|-----:|--------------------|----------------|
| `competitor_feature` | 30 | `gap_explorer` | `sim-algorithm-backlog.md`, `sim-md-research-backlog.md` |
| `plan_debt` | 18 | `plan_verifier`, snapshot | runner backlogs (deferred master-plan rows) |
| `missing_package` | 3 | `gap_explorer` | `ecosystem-package-backlog.md` |
| `ui_ux` | 6 | `gui_ux_tester` / studio loop | `2026-05-24-studio-ui-ux-plan-loop.md` (orch-r4) |

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
python3 scripts/ecosystem-quality-grade.py   # benchmarks/
SWARM_OBSERVER_REQUIRE_NOTE=docs/ecosystem/orchestrator-notes/2026-05-30-orch-r2-competitor-stubs.md \
  ./scripts/swarm-observer-plan-gates.sh
```

**Ingest signals (this cycle):** `verticals_stubs=0`, `competitor_catalog=0` — rows already in registry from prior pass; ingest idempotent.

**Source paths:**

- `lic/benchmarks/competitive/verticals.toml` — 12+ stub/honesty verticals (`workload_class=stub`)
- `benchmarks/data/latest/ecosystem-explorer.json` — HPC library + catalog gaps (via ingest_competitor_catalog)
- Evidence: `benchmarks/data/latest/swarm-gap-actions.json` (generated 2026-05-30T04:06:48Z)

---

## Backlog patches applied (competitor_feature)

| Gap id | Patch target |
|--------|--------------|
| `gap-vertical-stub-md-lennard-jones` | `sim-md-research-backlog.md` |
| `gap-vertical-stub-pde-heat-2d` | `sim-algorithm-backlog.md` |
| `gap-vertical-stub-fea-linear-elasticity` | `sim-algorithm-backlog.md` |
| `gap-vertical-stub-cfd-lid-driven-cavity` | `sim-algorithm-backlog.md` |
| `gap-vertical-stub-drug-litl` … `qm-dft` | `sim-md-research-backlog.md` (9 rows) |
| HPC/benchmark red rows (`gap-hpc-*`, `gap-benchmark-red-*`) | Handoff only — no backlog mapping |

**Open infra gap:** `gap-infra-verticals-toml-missing-benchmarks-main` — `benchmarks/competitive/verticals.toml` not on benchmarks main; ingest falls back to `lic/benchmarks/competitive/verticals.toml`. Handoff: `gap_explorer` + PR to land WP-LIC-01 on benchmarks.

**Systemd:** No new lic plan loops. Route via `research-goals.yaml` `swarm_coverage` handoff → `gap_explorer`, `plan_verifier`, `issue_planner`.

---

## Registry reconciliation

- Closed: `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs` (evidence updated 2026-05-30)
- `swarm-observer-plan-backlog.md`: `orch-r2-competitor-stubs` → `completed`

---

## Self-heal actions (programmatic observer)

- `observer.retry_counts`: `{}` — no auto-retries this tick
- `stopped_agents`: `[]`
- Latest `control_plane_reports.swarm_health.healthy`: **true** (stale — briefing_hash `5ebb031963cff33b`, 2026-05-25)
- Async swarm dispatched heap agents + broad UX/PR cohort at 04:01Z; mass `error` at 03:58Z correlated with GitHub GraphQL rate limit

---

## Recommended control-plane fixes

| Path | Fix |
|------|-----|
| `li-cursor-agents/src/observer/` | Surface `swarm_degraded` when >10 concurrent SDK errors or GraphQL 403 in 5 min |
| `li-cursor-agents/src/backends/cursor-sdk-backend.js` | Mark orphan `running` runs incomplete after timeout |
| `benchmarks/scripts/pr-program*.py` | REST fallback when GraphQL `rate limit exceeded` |
| `benchmarks/scripts/workspace-dirty-sweep.py` | Skip `gh pr create` when rate-limited; queue retry |
| `lic/scripts/swarm-gap-ingest.py` | Resolve `verticals.toml` via `BENCHMARKS_ROOT/competitive/` then lic fallback (documented) |

---

## Human-only blockers

- GitHub GraphQL quota reset (~hourly) — blocks PR program, workspace sweep, merge queue
- Governance PR merges (roadmap branch protection)
- `gap-infra-verticals-toml-missing-benchmarks-main` — human merge of verticals.toml to benchmarks main

---

## Agent deliverable checklist

- [x] Ingest + apply-actions
- [x] Registry reconciled; orch-r2 closed
- [x] Orchestrator note + `data/runs/` report
- [x] Gates OK
- [ ] Push `cursor/swarm-observer-plan-loop` (pending GH_TOKEN)

**north_star_fit:** ecosystem + ai — competitor parity registry feeds numerics/sim research without weakening proof gates (PH-5b, PH-7e).
