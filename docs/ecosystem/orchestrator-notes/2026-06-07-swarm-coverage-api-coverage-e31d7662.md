# Orchestrator note — `swarm_coverage` @ `api-coverage`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `e31d7662`  
**Run:** `1780848226802`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **D** (66.8); `unattended_safe: false` |
| Gap registry | **64 open** — unchanged since 2026-05-31 apply |
| Ingest API | **Blocked** — SyntaxError fixed locally; PyYAML missing in Job |
| SDK auth | **OK** — `CURSOR_API_KEY` set |
| Unattended? | **No** — preflight GH rate limit + gap ingest infra gaps |

---

## api-coverage audit (gap orchestration APIs)

### Script / tool surface

| API / script | Status | Evidence |
|--------------|--------|----------|
| `swarm-gap-ingest.py` | **Broken → patched locally** | SyntaxError line 229; fix mirrors lic#867 |
| `swarm-gap-apply-actions.py` | Stale (2026-05-31) | Not re-run — ingest prerequisite failed |
| `ecosystem-quality-grade.py` | **OK** | Regenerated 2026-06-07T16:16:07Z |
| MCP `li-ecosystem-context` | Partial | `load_research_session`, `get_briefing_snapshot` available; no direct gap-registry reader |
| GitHub REST (preflight) | **Rate limited** | org_ci_audit exit 1, HTTP 403 |

### Registry handoff API coverage

All 64 open gaps have `handoff_to` arrays. Top targets:

- `swarm_observer` — 31 plan_debt runner todos (orchestration loop)
- `plan_verifier` — 9 master-plan partial phases
- `numerics_researcher` — 30 competitor_feature / vertical stubs
- `issue_planner` — 1 missing_package + master-plan rows
- `gap_explorer` — infra verticals.toml gap

No orphan gaps without handoff routes.

---

## Mode B reconciliation (this cycle)

| Gap kind | Open | Patched (last apply) | Next agent |
|----------|------|----------------------|------------|
| `missing_package` | 1 | 3 rows (2026-05-31) | `issue_planner` |
| `plan_debt` | 31 | 12 sim/security/studio patches | `plan_verifier`, runner-specific loops |
| `competitor_feature` | 30 | 9 vertical stubs → sim-md backlog | `numerics_researcher`, `bench_improver` |

**Blocked patch targets (no runner backlog mapping):**

- 9 ph-db todos (`wp-g-ci-cross-repo`, …) — need `ph-db` backlog file or implement-goals row
- 9 lic master-plan partial phases — human `plan_verifier` + issue_planner
- `orch-r3` / `orch-r4` swarm-observer todos — meta orchestration (this note closes partial orch-r3)

---

## Control-plane fix applied (local)

```python
# lic/scripts/swarm-gap-ingest.py — ingest_verticals_stubs fallback
vert = Path(
    os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))
) / "verticals.toml"
```

Ship via lic#867; add PyYAML to Job image before re-enabling programmatic ingest ticks.

---

## Swarm routing (no new systemd loops)

| Agent | Reason |
|-------|--------|
| `gap_explorer` | Reconcile `gap-infra-verticals-toml-missing-benchmarks-main`; refresh explorer after verticals.toml lands |
| `plan_verifier` | Refresh stale goal-directed snapshot; run plan_audit preflight (currently `--skip-slow`) |
| `issue_planner` | `pkg-line-profiler` seed + ph-db backlog mapping issue |
| `ci_maintainer` | 14 repos missing CI; briefing P0 |
| `pr_merger` | lip#52 merge queue rank 1 |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780848226802.md`
