# Orchestrator note — `orch-r6-api-coverage-gap-handoffs`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `221f7eac`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Work item:** Reconcile gap registry apply pipeline + MCP/control-plane API coverage for swarm meta-audit

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **C** (72.1); `unattended_safe: false` |
| Gap pipeline | **Blocked** — ingest syntax fixed; apply still needs `python3-yaml` in worker image |
| Open gaps | **64** (`competitor_feature` 30, `plan_debt` 31, `missing_package` 3) |
| API coverage lens | Catalog harness **114 pending**; **8 stdlib tier1** workload dirs missing; MCP missing gap/scorecard readers |
| Unattended? | **No** — preflight failures, stale snapshot, gap apply blocked |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (regenerated 2026-06-07T13:21:21Z).

---

## API-coverage audit (dimension focus)

### Benchmark catalog / harness API surface

| Signal | Count | Evidence |
|--------|------:|----------|
| `catalog.toml` rows | 187 | `benchmarks/data/latest/catalog-audit.json` |
| Harness pending | 114 | `catalog-audit.json` → `harness_pending_count` |
| Workload dir missing | 21 | `catalog-audit.json` → `workload_dir_missing_sample` (8× `tier1_stdlib/*`) |
| CSV evidence gap | 171 | `zero-missing-data-report.json` → `catalog_without_csv` |
| Tier5 HTTP scenarios pending charts | 12 | `dashboard-gap-report.json` → P1 `chart_pending` |

**Routing:** hand off `bench_improver` + `numerics_researcher` via `numerics_sota` goal for stdlib tier1 harness backfill; `issue_planner` for catalog path honesty (PH-5b).

### Control-plane + MCP API coverage

| API | Status | Gap |
|-----|--------|-----|
| `data/control-plane/state.json` | Bootstrapped this run | Observer should persist each supervisor tick |
| `data/control-plane/latest-report.json` | Bootstrapped this run | Same |
| MCP `get_briefing_snapshot` | OK with `benchmarks_root=/workspace/benchmarks` | Default fixture path wrong (`/app/fixtures/e2e-benchmarks/...`) |
| MCP `read_gap_registry` | **Missing** | Observer re-reads YAML manually each run |
| MCP `read_ecosystem_quality_report` | **Missing** | Scorecard regen requires shell |
| `li-ecosystem-context` handoffs | Partial | `list_pending_handoffs` unused when registry stale |

**Routing:** `issue_planner` on `li-cursor-agents` for MCP tool additions (`mcp`, `api-coverage` labels).

### Registry gap taxonomy (open rows)

| `gap_kind` | Open | Primary discoverer | Observer action |
|------------|-----:|-------------------|-----------------|
| `competitor_feature` | 30 | `gap_explorer` | Re-ingest after PyYAML; route sim/httpd backlogs |
| `plan_debt` | 31 | `plan_verifier`, `implementation_gaps` | Map snapshot `plan_pending` → registry; no new systemd loops |
| `missing_package` | 3 | `gap_explorer` | `ecosystem-package-backlog.md` → `issue_planner` |
| `ui_ux` | 0 open | `gui_ux_tester` | `orch-r4` still pending in plan backlog |

Swarm-observer plan rows `orch-r3` / `orch-r4` remain **pending** in `lic/docs/ecosystem/swarm-observer-plan-backlog.md`.

---

## Scripts executed

```bash
# Regenerated scorecard (fresh inputs)
cd /workspace/benchmarks
LI_CURSOR_AGENTS_ROOT=/app python3 scripts/ecosystem-quality-grade.py
# overall_score=72.1 grade=C unattended_safe=False

# Ingest syntax verified (apply blocked on PyYAML)
python3 -m py_compile /workspace/lic/scripts/swarm-gap-ingest.py  # OK
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# swarm-gap-ingest: PyYAML required (pip install pyyaml)
```

**Fix applied:** `lic/scripts/swarm-gap-ingest.py` — `ingest_verticals_stubs()` Path fallback (line 229 syntax + KeyError).

---

## Swarm routing (no new registry ids / no lic systemd loops)

| Next agent | Reason | north_star_fit |
|------------|--------|----------------|
| `pr_merger` | Merge queue rank 1: lip#52 | ecosystem |
| `ci_maintainer` | 14 repos missing CI (preflight exit 1) | ecosystem |
| `security_auditor` | 19 CWE Top-25 rows missing from catalog | secure, provable |
| `gap_explorer` | 64 open gaps; apply pipeline stale | ecosystem, ai |
| `plan_verifier` | Briefing health weak; plan audit skipped | provable |
| `issue_planner` | stdlib tier1 harness + MCP tool gaps | easy, ecosystem |

Handoffs cite `swarm_coverage` goal; product sim/httpd work stays on existing research goals (`md_sim_algorithms`, `chem_sim_algorithms`).

---

## Human-only blockers

- Governance PRs lic#1021/#1014 — human merge only
- CWE catalog expansion — security policy gated
- `trusted.lean` — human-approved issues only
- Protected `main` — feature branches + PRs only

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/catalog-audit.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/control-plane/state.json`
- `/app/data/control-plane/latest-report.json`
- `/app/data/runs/swarm_observer-1780837420346.md`
