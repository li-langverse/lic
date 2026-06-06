# Orchestrator note — `orch-r6-api-coverage`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Worker:** `5f653e23`  
**Research goal:** `swarm_coverage` @ dimension **`api-coverage`**  
**north_star_fit:** ecosystem, ai — catalog/harness API surface vs proof evidence

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (62.6)**; `unattended_safe: false` |
| API-coverage signal | **111 unknown** benchmarks; **114 harness_pending**; **21 workload dirs missing** |
| Gap pipeline | Ingest **unblocked** (env fallback fix); open gaps **64 → 62** |
| `orch-r6` | **Completed** — api-coverage routing table + handoffs documented |
| Unattended? | **No** — phantom repos, failed metrics PRs, missing CP observer state |

Programmatic prep: `lic/scripts/swarm-gap-ingest.py` + `lic/scripts/swarm-gap-apply-actions.py` @ 2026-06-06T09:02Z.

---

## api-coverage reconciliation

### Catalog / harness debt

| Signal | Count | Evidence |
|--------|-------|----------|
| Benchmark `unknown` (no Li result) | 111 | `benchmarks/data/latest/ecosystem-audit.json` |
| `harness_pending` catalog rows | 114 | `benchmarks/data/latest/catalog-audit.json` |
| Missing workload directories | 21 | `catalog-audit.workload_dir_missing_sample` |
| Dashboard chart pending (P1) | 12 | `benchmarks/data/latest/dashboard-gap-report.json` |

**Stdlib API rows (chart_pending):** `stdlib_binary_search`, `stdlib_dict_insert_lookup`, `stdlib_sort_int` — route to **`stdlib_researcher`** via `stdlib_ecosystem` goal, not new registry ids.

### Org API repos (blocked)

| Repo | Status | Action |
|------|--------|--------|
| `li-api-kit` | GitHub 404 | Human: create repo or delist from org CI manifest |
| `li-research-gateway` | 404 | Delist or scaffold when MCP lane ships |
| `li-research-ingest` | 404 | same |
| `li-research-mcp` | 404 | same |

Evidence: `benchmarks/data/latest/org-repo-ci-audit.json`.

### Gap registry (post-apply)

| `gap_kind` | Open | Primary handoff |
|------------|------|-----------------|
| `missing_package` | 1 | `issue_planner` → `pkg-line-profiler` |
| `plan_debt` | 31 | `plan_verifier`, sim/security backlogs |
| `competitor_feature` | 30 | `gap_explorer`, `numerics_researcher` |

Vertical stub competitor gaps patched to **`sim-md-research-backlog.md`** (apply log @ 09:02Z).

---

## Control-plane fix applied

**File:** `lic/scripts/swarm-gap-ingest.py`

- Replaced `os.environ["BENCHMARKS_COMPETITIVE"]` KeyError with env fallback to `benchmarks/workloads/competitive`.
- Fixed Path syntax on `verticals.toml` fallback (line 229 regression from partial merge).

```bash
cd lic && python3 scripts/swarm-gap-ingest.py
# registry gaps: 92; open 62
python3 scripts/swarm-gap-apply-actions.py
# wrote benchmarks/data/latest/swarm-gap-actions.json
```

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `issue_planner` | Register/delist phantom API repos; backlog todos for missing workload dirs |
| `gap_explorer` | Reconcile 111 unknown catalog IDs vs honest stubs |
| `stdlib_researcher` | Stdlib tier1 chart_pending + API surface audit |
| `ci_maintainer` | 6 audit_incomplete repos; unblock metrics PR CI |
| `numerics_researcher` | PH-7e catalog competitor gaps (proof-before-perf) |

Research goal `swarm_coverage` remains on `swarm_observer` in `li-cursor-agents/config/research-goals.yaml`.

---

## Registry plan-debt rows

- `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` — close when snapshot records `orch-r3` (std.summary/plot now closed in registry).
- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — UX dimension completed 2026-06-06 (worker `9b512426`); close on next ingest with snapshot refresh.

---

## Human-only

- Creating `li-api-kit` and research MCP repos is org governance — not auto-merged.
- Catalog row registration affecting PH ids requires human review on `benchmarks` main.
- Do not disable provability gates for harness shortcuts.

---

## Evidence paths

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/catalog-audit.json`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780735187243.md`
- `lic/docs/research/swarm_coverage/api-coverage/2026-06-06-whitepaper.md`
