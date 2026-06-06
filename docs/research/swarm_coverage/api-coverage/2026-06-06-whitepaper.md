# Swarm coverage — api-coverage dimension

**Goal id:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Agent:** `swarm_observer`  
**Run id:** `1780735187243`  
**Worker:** `5f653e23`  
**Generated:** 2026-06-06T09:05:00Z  
**north_star_fit:** ecosystem, ai — catalog and harness API surface coverage for proof-before-perf gates

**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/`  
**Status:** staged locally (research-findings repo not mounted)

---

## Abstract

This pass audits Li ecosystem **API coverage** through the benchmark catalog and org repo lens, under the swarm gap orchestration mandate. The catalog declares **187 rows** but **114 remain harness-pending** and **111 benchmarks lack Li execution evidence**. Gap ingest was broken by a missing `BENCHMARKS_COMPETITIVE` env var; remediation restored the apply pipeline and reduced open registry gaps from 64 to 62. The swarm cannot run unattended (`grade D`, `unattended_safe: false`) until phantom API repos are resolved and metrics PRs land.

---

## Method

1. Regenerated `ecosystem-quality-report.json` via `scripts/ecosystem-quality-grade.py`.
2. Read `catalog-audit.json`, `ecosystem-audit.json`, `dashboard-gap-report.json`, `org-repo-ci-audit.json`.
3. Reconciled `registry.yaml` + `swarm-gap-actions.json` after fixing and re-running gap ingest/apply.
4. Compared briefing `recommended_agents` vs heap plan for goal-orientation drift.

---

## Findings (api-coverage)

### Catalog vs harness

| Metric | Value | Source |
|--------|-------|--------|
| Catalog rows | 187 | `catalog-audit.json` |
| Harness pending | 114 | `catalog-audit.json` |
| Workload dir missing | 21 | `catalog-audit.json` |
| Ecosystem `unknown` | 111 | `ecosystem-audit.json` |
| Near-threshold (green adjacency) | 5 | briefing `ecosystem_audit.benchmarks.near_threshold` |

The gap between declared catalog API/benchmark surface and executable harness is the primary **api-coverage** debt. Stdlib tier1 rows (`stdlib_sort_int`, `stdlib_dict_insert_lookup`, `stdlib_binary_search`) appear in both `unknown` and dashboard `chart_pending`.

### Org API repos

Six org repos return HTTP 404 during CI audit, including **`li-api-kit`**. Until repos exist or are delisted, `ci_maintainer` cannot close the "missing CI" signal and API-kit documentation cannot anchor to a live repo.

### Gap orchestration

After ingest fix:

- **Open gaps:** 62 (30 competitor, 31 plan_debt, 1 missing_package)
- **Vertical stub patches:** competitor stub rows routed to `sim-md-research-backlog.md`
- **Package gap:** `gap-line-profiler-001` → `issue_planner`

---

## Recommendations

1. **Catalog honesty:** For each of 21 missing workload dirs, either add harness + workload tree or mark `catalog_lifecycle: planned` with stub-honest metadata.
2. **Stdlib lane:** Dispatch `stdlib_researcher` on P1 chart_pending stdlib IDs before expanding viz/CFD unknown rows.
3. **Org manifest:** Create or delist phantom repos; stop counting 404 repos as "missing CI on main."
4. **Control plane:** Persist observer `latest-report.json` / `state.json` to disk; bake `python3-yaml` in worker image.
5. **MCP:** Expose gap registry + quality report readers for api-coverage researcher sessions.

---

## Validity

| Grade | Rationale |
|-------|-----------|
| **B** | Primary metrics from regenerated machine artifacts; gap apply re-run post-fix; CP observer state absent (partial blind spot) |

---

## Artifacts (local)

| Path | Description |
|------|-------------|
| `/app/data/runs/swarm_observer-1780735187243.md` | Full observer digest |
| `lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r6-api-coverage-5f653e23.md` | Orchestrator routing |
| `benchmarks/data/latest/ecosystem-quality-report.json` | Grade D scorecard |
| `benchmarks/data/latest/swarm-gap-actions.json` | Apply pipeline output |

---

## References

- `docs/ecosystem/research-verticals.md` — research lane scheduling
- `docs/ecosystem/swarm-architecture.md` — retired systemd loops → agents control plane
- `config/research-goals.yaml` — `swarm_coverage` goal definition
