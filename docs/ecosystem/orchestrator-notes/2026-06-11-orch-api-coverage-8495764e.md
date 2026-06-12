# Orchestrator note — API-coverage gap orchestration (`8495764e`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `8495764e`  
**Run:** `1781202997538`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (conditional)** — grade **C** (76.1); `unattended_safe: true` |
| Gap prep | **Blocked** — PyYAML missing; last apply @ `00:05:46Z` |
| Open gaps | **62** (`competitor_feature` 30, `plan_debt` 31, `missing_package` 1) |
| API posture | REST complete when ops-server runs; Job pods lack CP disk + MCP read tools |
| CP artifacts | **Missing** — no `state.json` / `latest-report.json` |
| Unattended? | **Conditional** — agents run; gap refresh + health APIs incomplete |

---

## API-coverage reconciliation

Swarm gap orchestration requires **read APIs** that work in homelab, K8s org-research Jobs, and CI without brittle path knowledge.

### Working APIs (this run)

| API | Result |
|-----|--------|
| File: `ecosystem-quality-report.json` | ✅ refreshed `19:38:55Z` |
| File: `swarm-gap-actions.json` | ✅ `00:05:46Z` |
| File: `registry.yaml` | ✅ `00:05:45Z` |
| MCP `get_briefing_snapshot` + `benchmarks_root=/workspace/benchmarks` | ✅ returns heap + timestamp |
| MCP `list_pending_handoffs` | ✅ available |
| SDK `CURSOR_API_KEY` | ✅ present |

### Broken / missing APIs

| API | Gap |
|-----|-----|
| `swarm-gap-ingest.py` | `ModuleNotFoundError: yaml` |
| `GET /api/report`, `/api/swarm/health` | Ops-server not running in Job pod |
| `data/control-plane/state.json` | Absent — retry counts opaque |
| MCP `read_ecosystem_quality_report` | Not implemented |
| MCP `read_swarm_gap_registry` | Not implemented |
| `org_ci_audit` preflight | Exit 1 — 33 repos missing CI; GitHub 404s |
| `org_agent_kit_audit` | Exit 1 — `roadmap/agent-kit` not mounted |

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py      # → BLOCKED: PyYAML
python3 scripts/swarm-gap-apply-actions.py
# → benchmarks/data/latest/swarm-gap-actions.json
```

### Handoff routing (no new agent ids)

| Gap cluster | Handoff |
|-------------|---------|
| `gap-line-profiler-001` | `issue_planner` via `ecosystem-package-backlog.md` |
| Sim `plan_debt` + `competitor_feature` stubs | `md_sim_algorithms`, `chem_sim_algorithms` research goals → `numerics_researcher` |
| Security plan rows (`sec-r*`) | `offensive_security` goal → `security_auditor` |
| `orch-r3`, `orch-r4` (swarm-observer plan_debt) | Meta — complete via this goal + `ui_ux_quality` |
| Master-plan Doc-c (`gap-plan-debt-lic-master-plan-doc-c-*`) | Human governance — lic PR #1476 |

---

## Briefing vs scorecard drift

| Source | Top agents |
|--------|------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

**Action:** Patch `benchmarks/scripts/build-agent-briefing.py` to union scorecard recommendations into `heap_plan.flat_tasks` so gap orchestration agents receive dispatch signal.

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781202997538.md`
