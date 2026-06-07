# Orchestrator note — `orch-r10-api-coverage-gap-handoffs`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `d097e170`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Work item:** Unblock gap ingest/apply; reconcile open registry rows; route api-coverage catalog debt

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **D** (69.6); `unattended_safe: false` |
| `orch-r10` | **In progress** — ingest/apply ran after ingest fix; 62 open gaps |
| Api-coverage | 114 harness-pending catalog rows; 21 missing workload dirs (stdlib + tier5 HTTP) |
| `missing_package` | **1 open** — `gap-line-profiler-001` → `issue_planner` |
| Unattended? | **No** — merge queue, CI gaps, CP state missing, PyYAML not baked in image |

Programmatic prep: `lic/scripts/swarm-gap-ingest.py` + `lic/scripts/swarm-gap-apply-actions.py` @ 2026-06-07T08:16:42Z.

---

## Scripts executed

```bash
# Fixed lic/scripts/swarm-gap-ingest.py — BENCHMARKS_COMPETITIVE Path fallback
apt-get install -y python3-yaml   # ephemeral; bake in worker image

cd /workspace/lic
python3 scripts/swarm-gap-ingest.py
# registry gaps: 92 ({'missing_package': 5, 'plan_debt': 57, 'competitor_feature': 30})

python3 scripts/swarm-gap-apply-actions.py
# wrote /workspace/benchmarks/data/latest/swarm-gap-actions.json
# open_gaps: 62 (missing_package: 1, plan_debt: 31, competitor_feature: 30)
```

---

## Gap reconcile by kind

### `missing_package` (1 open)

| Registry id | Backlog todo | Handoff |
|-------------|--------------|---------|
| `gap-line-profiler-001` | `pkg-line-profiler` | `issue_planner` |

Closed since orch-r3: `std.summary`, `std.plot`, `std.io`, `std.csv`.

### `plan_debt` (31 open)

- **8 sim todos patched** → `sim-algorithm-backlog.md`, `sim-md-research-backlog.md`, etc.
- **23 deferred** — no runner backlog mapping (master-plan partial phases) → `plan_verifier`, `issue_planner`

### `competitor_feature` (30 open)

- Patched sim/httpd competitor stubs → respective backlogs
- Handoff: `gap_explorer`, `numerics_researcher` (research lane — **no new systemd loops**)

### `ui_ux` (skipped)

- `lic-studio-ui` plan backlog not mounted — skip until workspace includes studio worktree

---

## Api-coverage routing (catalog)

Evidence: `benchmarks/data/latest/catalog-audit.json`

| Priority | Catalog debt | Route |
|----------|--------------|-------|
| P1 | 8 stdlib workload dirs missing | `bench_improver` + `issue_planner` |
| P1 | tier5 HTTP scenarios (lb_*, rate_limit_429, https_static) | `bench_improver` + httpd plan todos |
| P2 | 114 harness-pending | `ecosystem_grader` narrative + phased harness PRs |

Do **not** invent new agent registry ids. Use existing `research-goals.yaml` handoffs.

---

## Swarm routing (next dispatch)

| Agent | Reason |
|-------|--------|
| `pr_merger` | Merge queue: lip#52 (gate-ready) |
| `ci_maintainer` | 14 repos missing CI |
| `security_auditor` | CWE Top25 catalog gaps (19 missing) |
| `gap_explorer` | 62 open registry rows; competitor_feature pressure |
| `plan_verifier` | 31 plan_debt; refresh plan audit preflight |
| `issue_planner` | `pkg-line-profiler` seed issue |

---

## Control-plane blockers (not lic product code)

1. Bake `python3-yaml` + env defaults in org-research worker image
2. Persist `data/control-plane/state.json` each supervisor tick
3. Set `LI_CURSOR_AGENTS_ROOT=/app` so quality grade samples runs
4. MCP tools: `read_gap_registry`, `read_ecosystem_quality_report`

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780818512010.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-07-whitepaper-d097e170.md`
