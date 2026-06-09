# Swarm gap orchestration — API coverage audit

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `a2bf5d4e`  
**Date:** 2026-06-08  
**north_star_fit:** ecosystem, ai — provable orchestration before leaf-agent churn  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/` (staging in lic)

---

## Abstract

Swarm gap orchestration depends on a chain of filesystem artifacts (registry YAML, gap-actions JSON, ecosystem quality scorecard, agent briefing). This audit maps **programmatic surfaces** agents and MCP clients can call today versus what `swarm_observer` needs for unattended meta-audits. We find ingest/apply CLI is sufficient when env + PyYAML are present, but **read-path API coverage is incomplete** — forcing meta-agents to shell out or read raw paths, which breaks in org-research Job sandboxes.

---

## Method

1. Ran checklist from `swarm_observer` system prompt against live artifacts (2026-06-08T02:17Z briefing).
2. Executed `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` after remediating syntax/env bugs.
3. Inventoried MCP tools in `li-ecosystem-context` and dashboard research APIs.
4. Regenerated scorecard with `LI_CURSOR_AGENTS_ROOT=/app`.

Evidence paths cited inline.

---

## API inventory

### CLI / scripts (write path — good)

| Script | Input env | Output | Status |
|--------|-----------|--------|--------|
| `lic/scripts/swarm-gap-ingest.py` | `LIC_ROOT`, optional `BENCHMARKS_COMPETITIVE` | `lic/data/swarm-gap-registry/registry.yaml` | ✅ after Path fix |
| `lic/scripts/swarm-gap-apply-actions.py` | registry + backlogs | `benchmarks/data/latest/swarm-gap-actions.json` | ✅ |
| `benchmarks/scripts/ecosystem-quality-grade.py` | briefing, snapshot, `LI_CURSOR_AGENTS_ROOT` | `ecosystem-quality-report.json` | ✅ with env |

### MCP read path (partial)

| Tool | Returns | Missing for swarm_coverage |
|------|---------|----------------------------|
| `get_briefing_snapshot` | Subset of briefing keys | `recommended_agents`, gap counts, preflight exit codes |
| `list_org_repos` | Repo names | — |
| `describe_package` | Package row | — |
| `load_research_session` | Session state | — |
| *(none)* | Gap registry | **`read_gap_registry`** |
| *(none)* | Apply actions | **`read_gap_actions`** |
| *(none)* | Quality scorecard | **`read_ecosystem_quality_report`** |

Source: `li-cursor-agents/src/mcp/li-ecosystem-context-mcp.ts`

### Dashboard HTTP (read path — partial)

| Route | Coverage |
|-------|----------|
| `GET /api/research/runs/:id` | Run trace, `whitepaper_path`, goal metadata |
| `GET /api/goals` | Enabled research goals + cadence |
| *(none)* | Swarm health, gap-apply last run, observer retry_counts |

---

## Findings

1. **Ingest fragility:** Missing `BENCHMARKS_COMPETITIVE` caused `KeyError` before fallback; fixed by defaulting to `benchmarks/workloads/competitive/verticals.toml`.
2. **PyYAML dependency:** Ingest requires PyYAML; not in base org-research image — blocked automated ticks until package install.
3. **Runs path mismatch:** Quality grade sampled 0 runs until `LI_CURSOR_AGENTS_ROOT=/app`; document default in grade script.
4. **Control-plane bootstrap:** Fresh containers lack `state.json` / `latest-report.json`; observer retry ledger unavailable — not an API gap but affects self-heal telemetry.
5. **62 open gaps** remain orchestration debt; API coverage does not reduce count — it enables agents to reconcile without shell.

---

## Recommendations

1. Add three MCP read tools (registry, actions, quality report) with schema-validated JSON responses.
2. Bake `python3-yaml` + env defaults in org-research Job spec.
3. Extend dashboard with gap-apply status + last ingest timestamp.
4. Wire `runSwarmGapIngestTick()` failure to observer finding `gap_ingest_blocked` with auto-heal hint.

---

## Handoffs

| Agent | Work |
|-------|------|
| `gap_explorer` | Reconcile 30 competitor_feature rows |
| `plan_verifier` | Refresh goal-directed snapshot; close orch-r3/r4 |
| `issue_planner` | `gap-line-profiler-001` → issue |

**PH alignment:** ecosystem orchestration supports proof-before-perf pillar ordering — no numerics shortcuts.

---

## References

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `li-cursor-agents/data/runs/swarm_observer-1780883650261.md`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r6-api-coverage.md`
