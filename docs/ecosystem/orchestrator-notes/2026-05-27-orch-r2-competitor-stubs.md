# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-27  
**Agent:** `swarm_observer`  
**Branch:** _(local plan-loop branch)_  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows; apply backlog patches + handoffs via registry/actions.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 67.9; `unattended_safe: false`) |
| Primary blockers | **Failing PR CI** (56), **missing CI on main** (33), **2 red benchmarks**, **preflight failures** (2) |
| Gap registry (post-ingest) | **74 total gaps**, **49 open**: 3 `missing_package`, 24 `plan_debt`, 22 `competitor_feature` |
| Unattended? | **No** — too many CI failures + registry/backlog churn + possible stuck SDK runs |

Evidence inputs:

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/data/swarm-gap-registry/registry.yaml`

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

---

## What changed this cycle

- **Registry updated**: ingest added **3** new `plan_debt_snapshot` rows; `competitor_catalog` and `verticals_stubs` added **0** (see next section).
- **Actions applied** (selected):
  - patched missing packages → `docs/ecosystem/ecosystem-package-backlog.md` (`pkg-line-profiler`, `pkg-std-summary`, `pkg-std-plot`)
  - patched sim/security research backlog items (plan-debt) → `docs/ecosystem/*-backlog.md`
  - appended httpd plan-debt todos into `docs/superpowers/plans/2026-05-16-li-httpd-plan.md`
  - appended a competitor stub gap to `docs/ecosystem/sim-md-research-backlog.md` (`gap-vertical-stub-md-lennard-jones`)

All patches are enumerated in `benchmarks/data/latest/swarm-gap-actions.json`.

---

## Findings (competitor stubs ingest)

| Symptom | Impact | Evidence | Severity |
|---|---|---|---|
| `verticals.toml` stub ingest produced 0 rows | Blocks “stub honesty” competitor_feature expansion from `benchmarks` → registry | `scripts/swarm-gap-ingest.py` output: `added.verticals_stubs: 0`; registry row `gap-infra-verticals-toml-missing-benchmarks-main` | High |
| Competitor catalog ingest produced 0 rows | Catalog-gap signals not flowing into registry from explorer digest | `scripts/swarm-gap-ingest.py` output: `added.competitor_catalog: 0` | Medium |

Interpretation: `orch-r2` goal is partially blocked by missing/incorrect location of `benchmarks/competitive/verticals.toml` on the canonical branch used by ingest (registry already includes an infra gap to fix this).

---

## Self-heal actions taken (programmatic observer parity)

- Ran ingest/apply to keep registry/actions canonical and patch backlogs automatically where mapped.
- No new systemd plan loops suggested/installed here (registry may *suggest* loops, but this run does not recommend systemd installs).

---

## Human-only blockers

- Governance merges / protected branches for CI rollouts and policy changes.
- Any `roadmap` PRs (human review required).
- SDK auth outages (if `CURSOR_API_KEY` missing/invalid, automatic retries will not recover).

---

## Next recommended handoffs (registry-driven)

- `gap-infra-verticals-toml-missing-benchmarks-main` → `gap_explorer`, `docs_maintainer` (restore/land canonical `benchmarks/competitive/verticals.toml` so ingest works)
- `gap-benchmark-red-*` rows (`PH-5b`, `PH-7e`) → `bench_improver`, `numerics_researcher` (proof-before-perf)
- Missing packages (`pkg-line-profiler`, `pkg-std-summary`, `pkg-std-plot`) → `issue_planner`, `package_architect`

---

## Agent deliverable checklist

- [x] Ingest + apply-actions executed
- [x] Orchestrator note written (`orch-r2`)
- [x] Evidence paths cited

