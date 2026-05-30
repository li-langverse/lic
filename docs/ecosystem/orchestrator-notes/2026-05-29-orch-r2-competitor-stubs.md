# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-29  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Branch:** `cursor/swarm-observer-plan-loop`  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows; apply backlog patches.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 60.3; `unattended_safe: false`) |
| `competitor_feature` open | **30** (stable after ingest) |
| Ingest delta | `verticals_stubs: 0`, `competitor_catalog: 0` — rows already present |
| Apply delta | **8** vertical-stub rows appended to `sim-md-research-backlog.md` |
| Unattended? | **No** — 35 failing PRs, supervisor reconcile noise in DB |

`orch-r2-competitor-stubs` is **complete** for registry ingest + backlog apply. Remaining competitor rows route to `gap_explorer`, `numerics_researcher`, and sim/httpd implement goals — not new lic systemd loops.

---

## Scripts executed

```bash
cd lic
python3 scripts/swarm-gap-ingest.py    # 79 gaps in file; +0 verticals_stubs this pass
python3 scripts/swarm-gap-apply-actions.py
```

**Outputs:**

- `lic/data/swarm-gap-registry/registry.yaml` — `updated_at: 2026-05-29T10:53:00Z`
- `benchmarks/data/latest/swarm-gap-actions.json` — `open_gaps: 54` (30 `competitor_feature`)

---

## Registry: competitor / vertical coverage

| Source | Rows | Status |
|--------|------|--------|
| `gap-vertical-stub-*` (MD, PDE, FEA, CFD, drug, bio, viz, cinematic, mmo, qm) | 12+ in registry | `open`, `gap_kind: competitor_feature` |
| `gap-competitor-*` (catalog, chapel, pure_li, etc.) | remainder of 30 | `open` |
| `verticals.toml` on benchmarks main | infra gap if missing on main | track via `gap_explorer` / docs PR |

**Ingest:** No new stub rows — prior passes (2026-05-25 r0/r1) already ingested verticals + explorer catalog.

**Apply (this pass):** Appended competitor gap refs to `docs/ecosystem/sim-md-research-backlog.md` for:

- `gap-vertical-stub-md-lennard-jones`
- `gap-vertical-stub-drug-litl`, `bio-litl`, `scientific-viz`
- `gap-vertical-stub-cinematic-encode`, `color-grade`, `audio-sync`
- `gap-vertical-stub-mmo-shard`, `qm-dft`

Evidence: `benchmarks/data/latest/swarm-gap-actions.json` (`patch: appended gap-competitor-…`).

---

## Handoffs (swarm goals — no new agent ids)

| Gap kind | Route to | Notes |
|----------|----------|-------|
| `competitor_feature` (sim verticals) | `numerics_researcher`, `bench_improver` via implement goals | sim-algo / sim-md backlogs patched |
| `competitor_feature` (httpd tier5) | `bug_fixer`, httpd runner `plan_pending` | existing httpd plan-loop runner |
| `competitor_feature` (studio/cinematic) | `studio_ui_ux_builder` when `orch-r4` runs | deferred ui_ux linkage |

Do **not** install `install-goal-plan-loop-systemd.sh` for retired loops — see `docs/ecosystem/swarm-architecture.md`.

---

## Registry closure

- Close `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs` (`plan_debt`) → `status: closed`
- Mark `orch-r2-competitor-stubs` **completed** in `docs/ecosystem/swarm-observer-plan-backlog.md`

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/runs/swarm_observer-2026-05-29-swarm-coverage.md`
- `lic/docs/ecosystem/sim-md-research-backlog.md`

---

## Deferred

- `orch-r3-missing-package-sweep` — 3 open `missing_package` gaps (line_profiler, std.summary, std.plot)
- `orch-r4-ui-ux-signals` — studio-ui-ux / `gui_ux_tester` → `ui_ux` registry rows
- benchmarks `verticals.toml` on **main** if branch-only — human/docs_maintainer PR
