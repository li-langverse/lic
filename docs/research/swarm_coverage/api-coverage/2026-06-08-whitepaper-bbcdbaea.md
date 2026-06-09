# Swarm gap orchestration — API-coverage dimension

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `bbcdbaea`  
**Date:** 2026-06-08  
**north_star_fit:** Ecosystem orchestration (proof → easy → fast); competitive API surface honesty before perf claims

---

## Abstract

This whitepaper audits the **api-coverage** lens for Li's swarm gap orchestration pipeline. Two API surfaces dominate: (1) the competitive vertical registry (`verticals.toml`) feeding `swarm-gap-ingest.py`, and (2) the org GitHub API catalog probed by `ensure-org-repo-ci.py`. Both are currently degraded: ingest cannot run due to a Python syntax error and missing PyYAML; org CI audit reports 25 HTTP 404 repos. Until these are fixed, the 64-row gap registry is frozen and `unattended_safe` is false.

---

## 1. Competitive vertical API coverage

**Source:** `benchmarks/workloads/competitive/verticals.toml`

| Metric | Value |
|--------|-------|
| Total vertical rows | 18+ |
| `workload_class = "stub"` | 12 |
| Honest-oracle rows | 6 (e.g. `md_lennard_jones`, `pde_heat_2d` with cpp oracle but stub workload) |

The `ingest_verticals_stubs()` function in `lic/scripts/swarm-gap-ingest.py` scans stub/honest rows and promotes them to `competitor_feature` gaps in `registry.yaml`. This is the primary **api-coverage** bridge between benchmarks competitive intel and swarm handoffs.

**Failure mode (2026-06-08):**

```
SyntaxError: unterminated string literal (line 229)
```

The `BENCHMARKS_COMPETITIVE` Path fallback was malformed, preventing any vertical stub ingest. Fixed locally:

```python
vert = Path(
    os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))
) / "verticals.toml"
```

---

## 2. Org repository API coverage

**Source:** `benchmarks/data/latest/org-repo-ci-audit.json` (2026-06-08T08:55Z)

| Bucket | Count |
|--------|-------|
| `repos_ok` | 50 |
| `repos_audit_incomplete` (HTTP 404) | 25 |
| `repos_missing_ci_main` (ecosystem metrics) | 12 |

Phantom repos (e.g. `li-api-kit`, `li-os`, `li-research-mcp`) appear in the org catalog but return `gh: Not Found`. This inflates `org_ci_audit` preflight failures and blocks unattended CI maintenance.

**Recommendation:** Prune catalog or create repos — human-gated; `ci_maintainer` cannot heal 404s programmatically.

---

## 3. Gap registry API (frozen)

| Field | Value |
|-------|-------|
| `open_gaps` | 64 |
| `missing_package` | 3 |
| `plan_debt` | 31 |
| `competitor_feature` | 30 |
| Last apply | 2026-05-31T01:45:58Z |

Without live ingest, new vertical stubs and plan snapshot changes do not flow to `swarm-gap-actions.json`. The api-coverage dimension therefore measures **pipeline health**, not just data completeness.

---

## 4. Control-plane API gaps

| Endpoint / artifact | Expected | Observed |
|--------------------|----------|----------|
| `data/control-plane/latest-report.json` | swarm_health per tick | **Missing** |
| `data/control-plane/state.json` | retry_counts, stopped_agents | **Missing** |
| `ecosystem-quality-grade.py` runs_dir | `/app/data/runs` | `/workspace/li-cursor-agents/data/runs` (0 sampled) |

These path mismatches cause the scorecard to under-report swarm execution errors in containerized workers.

---

## 5. Recovery sequence

1. Merge `swarm-gap-ingest.py` Path fallback fix (`lic`)
2. Bake `python3-yaml` in org-research worker image (`li-cursor-agents`)
3. Run `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py`
4. Fix grader `runs_dir` default (`benchmarks`)
5. Dispatch `gap_explorer` for 30 `competitor_feature` rows
6. `ci_maintainer` for org 404 + missing CI

---

## References

- `lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r17-api-coverage-gap-orchestration.md`
- `/app/data/runs/swarm_observer-1780908855046.md`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `li-cursor-agents/docs/ecosystem/research-verticals.md` — `swarm_coverage` goal

**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/` (out of band)
