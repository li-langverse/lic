# Orchestrator note — `orch-r6-api-coverage`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage` · worker `a2bf5d4e`  
**Work item:** Gap registry ingest/apply API surface + MCP read coverage audit

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **C** (75.6); `unattended_safe: true` |
| Gap ingest | **Green** after Path + env fallback fix + `python3-yaml` |
| Open gaps | **62** (31 plan_debt, 30 competitor_feature, 1 missing_package) |
| MCP gap | No read tools for registry / gap-actions / quality scorecard |
| Unattended? | **Marginal** — scripts runnable; MCP + snapshot refresh need follow-up |

Programmatic prep @ 2026-06-08T02:19Z:

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
LI_CURSOR_AGENTS_ROOT=/app python3 ../benchmarks/scripts/ecosystem-quality-grade.py
```

---

## api-coverage findings

| Surface | Covered today | Gap |
|---------|---------------|-----|
| MCP `get_briefing_snapshot` | Partial keys from benchmarks briefing | Path assumes benchmarks root; no gap/quality keys |
| MCP `list_org_repos` / `describe_package` | Yes | — |
| Gap registry YAML | Filesystem only | Need `read_gap_registry` MCP tool |
| `swarm-gap-actions.json` | Filesystem only | Need `read_gap_actions` MCP tool |
| `ecosystem-quality-report.json` | Filesystem only | Need `read_ecosystem_quality_report` |
| Dashboard `/api/research/runs` | Run metadata + whitepaper path | No gap-apply status panel |
| Env contract | `LIC_ROOT`, `LI_CURSOR_AGENTS_ROOT` | `BENCHMARKS_COMPETITIVE` undocumented; caused ingest KeyError |

Evidence: `li-cursor-agents/src/mcp/li-ecosystem-context-mcp.ts`, `li-cursor-agents/data/runs/swarm_observer-1780883650261.md`

---

## Gap reconciliation (open → handoff)

| Priority gaps | Handoff |
|---------------|---------|
| `gap-line-profiler-001` (missing_package) | `issue_planner` |
| sim plan_debt (`sim-p1-*`, `md-r3-oracle-plan`, chem rows) | `numerics_researcher` via sim backlogs |
| security-research (`sec-r1`…`sec-r3`) | `security_auditor` / `offensive_security` goal |
| ph-db deferred rows (9) | `goal_researcher` + ph-db implement lane |
| competitor_feature bench reds | `bench_improver`, `numerics_researcher` |

No new agent registry ids. No lic systemd plan loops.

---

## Swarm routing

| Next agent | Reason |
|------------|--------|
| `gap_explorer` | `gap_pressure` score 60 — 62 open registry rows |
| `plan_verifier` | Refresh snapshot; close `orch-r3`/`orch-r4` plan_debt |
| `issue_planner` | `pkg-line-profiler` + std module issues |
| `ci_maintainer` | 12 repos missing CI |

---

## Registry plan-debt rows

- `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` — close after snapshot records completion (this note + ingest green)
- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — route studio-ux-16/17 to `gui_ux_tester`

---

## Human-only

- MCP tool additions require `li-cursor-agents` PR + `npm test`
- Product implementation of missing packages — no auto-merge on `lic` master

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `li-cursor-agents/data/runs/swarm_observer-1780883650261.md`
- `lic/docs/research/swarm_coverage/api-coverage/2026-06-08-whitepaper-a2bf5d4e.md`
