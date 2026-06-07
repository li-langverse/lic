# Swarm gap orchestration — API coverage dimension

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `221f7eac`  
**Date:** 2026-06-07  
**north_star_fit:** ecosystem, ai — meta-orchestration must expose complete, stable APIs for agents to audit without shell fallbacks.

**Publish target (deferred):** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/`

---

## Abstract

This pass audits **API coverage** for the swarm gap orchestration control plane: benchmark catalog harness completeness, MCP tool surface for meta-agents, and control-plane persistence endpoints. The swarm is **degraded but recoverable** (grade C, 72.1). Gap ingest syntax is fixed; gap apply remains blocked on missing `python3-yaml` in the org-research worker image.

---

## 1. Benchmark catalog API coverage

Source: `benchmarks/data/latest/catalog-audit.json` (2026-06-07 briefing embed).

| Metric | Value | Implication |
|--------|------:|-------------|
| Catalog rows | 187 | Broad surface declared |
| Harness pending | 114 | 61% of catalog lacks runnable harness |
| Workload dir missing | 21 | Includes 8 stdlib tier1 micro-benches |
| Problem size missing | 37 | Bench matrix incomplete for regression gates |

Priority backfill (proof-before-perf):

1. **stdlib tier1** — `stdlib_list_push_pop`, `stdlib_dict_insert_lookup`, … (8 ids)  
2. **tier5 HTTP** — `https_static`, `lb_*`, `rate_limit_429` (chart_pending in dashboard)  
3. **PH-5b honesty** — align catalog paths vs competitive vertical stubs

---

## 2. MCP + control-plane API gaps

| Consumer | Expected API | Current state |
|----------|--------------|---------------|
| `swarm_observer` | Read scorecard JSON | Shell: `ecosystem-quality-grade.py` |
| `swarm_observer` | Read gap registry | Direct file read of `registry.yaml` |
| `gap_explorer` | `get_briefing_snapshot` | Works with explicit `benchmarks_root` |
| Dashboard | `latest-report.json` | Was ENOENT; bootstrapped 2026-06-07 |
| Observer | `state.json` retry/stop counts | Was empty; bootstrapped 2026-06-07 |

Recommended MCP additions on `li-ecosystem-context`:

- `read_ecosystem_quality_report(benchmarks_root?)`
- `read_gap_registry(lic_root?, status=open)`

Fix default fixture path in `get_briefing_snapshot` (currently `/app/fixtures/e2e-benchmarks/...`).

---

## 3. Gap registry apply pipeline

| Stage | Status | Blocker |
|-------|--------|---------|
| `swarm-gap-ingest.py` | Syntax **fixed** | PyYAML import for registry I/O |
| `swarm-gap-apply-actions.py` | Not run | PyYAML |
| `swarm-gap-actions.json` | Stale (2026-05-31) | 64 open gaps unchanged |

Open gap mix: 30 competitor_feature, 31 plan_debt, 3 missing_package. No `ui_ux` open rows; studio signals deferred to `orch-r4`.

---

## 4. Goal orientation vs briefing

| Source | Top dispatch |
|--------|--------------|
| Briefing (2026-06-07T13:20Z) | `pr_merger`, `ci_maintainer`, `security_auditor` |
| Scorecard (fresh) | `gap_explorer`, `ci_maintainer`, `plan_verifier`, `security_auditor`, `pr_merger` |
| Heap plan | `pr_merger` (P10), `ci_maintainer` (P50) |

**Drift:** Low — merge + CI aligned; scorecard adds gap/plan_verifier from degraded gap_pressure and briefing_health dimensions.

---

## 5. Recommendations

1. Bake `python3-yaml` + set `LI_CURSOR_AGENTS_ROOT=/app` in org-research worker image.  
2. Merge lic ingest Path fallback; re-run ingest + apply.  
3. Add MCP readers for scorecard + registry (reduce observer shell dependency).  
4. Persist control-plane state each supervisor tick (`src/control-plane/build-report.ts`).  
5. Dispatch `bench_improver` for stdlib tier1 harness backfill (api-coverage / PH-5b).

---

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/catalog-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r6-api-coverage-gap-handoffs-221f7eac.md`
- `/app/data/runs/swarm_observer-1780837420346.md`
