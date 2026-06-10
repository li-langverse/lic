# Swarm gap orchestration — API-coverage dimension

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `e0f2dd4a`  
**Date:** 2026-06-10  
**north_star_fit:** ecosystem, ai — Vision-LLM agent JSON diagnostics require honest programmatic APIs  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/`

---

## Abstract

Swarm gap orchestration (registry ingest, backlog apply, handoffs) depends on **read APIs** that work identically in homelab, K8s org-research Jobs, and CI. This pass audits api-coverage for the `swarm_coverage` meta-goal and finds REST endpoints largely complete in `li-cursor-agents`, while MCP tooling and control-plane disk persistence leave orchestration blind spots that distort grading and block unattended gap refresh.

---

## Method

1. Read scorecard (`ecosystem-quality-report.json`) and gap artifacts (`registry.yaml`, `swarm-gap-actions.json`).
2. Inspect MCP server `li-ecosystem-context` tool catalog via runtime discovery.
3. Cross-check REST routes in `src/ops-server.ts` and `src/db-api/index.ts`.
4. Attempt live `swarm-gap-ingest.py` to validate CLI API dependencies.
5. Compare briefing `recommended_agents` vs scorecard recommendations for orchestration signal drift.

---

## API inventory

### Control-plane REST (when ops-server running)

| Endpoint | Payload highlights | Observer use |
|----------|-------------------|--------------|
| `GET /api/swarm/health` | `findings`, `degraded`, retry counts | Checklist §2–3 |
| `GET /api/report` | `swarm_health`, `interventions`, `recent_runs` | Checklist §2 |
| `GET /api/goals` | enabled research goals + cadence | Mode B routing |
| `GET /api/swarm/briefing` | scorecard, research status | Briefing alignment |
| `GET /api/runs` | terminal + running runs | Error classification |
| `GET /api/interventions` | healer dispatch log | Self-heal audit |

### MCP (`li-ecosystem-context`)

| Tool | Status | Gap |
|------|--------|-----|
| `get_briefing_snapshot` | partial | No quality report or gap actions |
| `list_pending_handoffs` | ok | — |
| `load_research_session` | ok | schema drift risk |
| `describe_package` | ok | org package rows |
| `read_ecosystem_quality_report` | **missing** | checklist §1 |
| `read_swarm_gap_registry` | **missing** | Mode B §1 |

### File artifacts (Job pod fallback)

| File | Mount | This run |
|------|-------|----------|
| `ecosystem-quality-report.json` | `/workspace/benchmarks/data/latest/` | ✅ refreshed 18:09Z |
| `swarm-gap-actions.json` | same | ✅ 14:45Z apply |
| `registry.yaml` | `/workspace/lic/data/swarm-gap-registry/` | ✅ |
| `state.json` / `latest-report.json` | `/app/data/control-plane/` | ❌ absent |

---

## Findings

### 1. Org-research Jobs lack REST parity

K8s researcher pods mount benchmarks + lic but typically **not** the ops-server. Meta-agents must use MCP or explicit file paths. Missing MCP read tools force brittle path knowledge — a coverage defect for `swarm_coverage`.

### 2. Control-plane persistence API gap

Without `state.json` and `latest-report.json`, the programmatic observer cannot expose `observer.retry_counts` or intervention history to auditors. Grade dimension `swarm_execution` reads as 100 (0 errors) while orchestration self-heal is **unobservable**.

### 3. Gap ingest CLI blocked on PyYAML

```
swarm-gap-ingest: PyYAML required (pip install pyyaml)
```

This is an **infra API contract** failure: the ingest script's dependency is not declared in the worker image. Apply artifacts can remain fresh while registry drift accumulates.

### 4. Orchestration signal drift

| Source | Top recommendations |
|--------|---------------------|
| Briefing heap | `ci_maintainer` only |
| Briefing snapshot | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

Without a unified API surfacing scorecard `recommended_agents` into briefing heap, gap orchestration agents starve despite 62 open registry rows.

### 5. `runs_sampled` sensitivity (regression guard)

When grader `runs_dir` mis-resolves, `swarm_execution` collapses and `unattended_safe` flips false. Auto-detect `/app/data/runs` when present (shipped in grader); set `LI_CURSOR_AGENTS_ROOT=/app` on Jobs.

---

## Recommendations

| Priority | Action | Owner |
|----------|--------|-------|
| P0 | Add MCP `read_ecosystem_quality_report`, `read_swarm_gap_registry` | `li-cursor-agents` |
| P0 | Bake `python3-yaml`; unblock ingest | deploy |
| P1 | Bootstrap CP disk mirrors each supervisor tick | observer |
| P1 | Align briefing heap with scorecard recommendations | briefing pipeline |
| P2 | Extend `get_briefing_snapshot` with gap_pressure keys | MCP |

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781110863279.md`

---

## Related

- `docs/ecosystem/swarm-architecture.md`
- `docs/ecosystem/research-verticals.md` — `swarm_coverage` goal row
- Prior pass: `2026-06-10-whitepaper-746e2c2c.md`
