# Orchestrator note — API-coverage gap orchestration (`e77aa378`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `e77aa378`  
**Run:** `1781218298082`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (conditional)** — grade **C** (76.1); `unattended_safe: true` |
| Gap prep | **Blocked** — PyYAML missing; last apply @ `00:05:46Z` |
| Open gaps | **62** (`competitor_feature` 30, `plan_debt` 31, `missing_package` 1) |
| API posture | File artifacts OK; MCP read gaps; CP disk mirrors absent |
| Unattended? | **Conditional** — agents run; gap refresh + heal audit incomplete |

---

## API-coverage reconciliation

Swarm gap orchestration requires read APIs that work in homelab, K8s org-research Jobs, and CI without brittle path knowledge.

### Working

| API | Result |
|-----|--------|
| `ecosystem-quality-report.json` | ✅ refreshed `23:38:55Z` |
| `swarm-gap-actions.json` | ✅ present (stale apply) |
| `registry.yaml` | ✅ `00:05:45Z` |
| MCP `get_briefing_snapshot` + `benchmarks_root` | ✅ |
| SDK `CURSOR_API_KEY` | ✅ |

### Broken / missing

| API | Gap |
|-----|-----|
| `swarm-gap-ingest.py` | `ModuleNotFoundError: yaml` |
| CP `state.json`, `latest-report.json` | Absent |
| MCP `read_ecosystem_quality_report` | Not implemented |
| MCP `read_swarm_gap_registry` | Not implemented |
| REST swarm health endpoints | Ops-server not in Job pod |

---

## Gap routing (no new agent ids)

| Cluster | Handoff |
|---------|---------|
| `gap-line-profiler-001` | `issue_planner` → `ecosystem-package-backlog.md` |
| Sim `plan_debt` rows | `md_sim_algorithms`, `chem_sim_algorithms` → `numerics_researcher` |
| `sec-r1`–`sec-r3` | `offensive_security` → `security_auditor` |
| `orch-r3-missing-package-sweep` | This meta pass + post-PyYAML `gap_explorer` |
| `orch-r4-ui-ux-signals` | Existing `ui_ux_quality` → `gui_ux_tester` |
| Doc-c master-plan | Human — lic PR #1476 |

---

## Briefing drift

| Source | Agents |
|--------|--------|
| Briefing heap | `ci_maintainer` only |
| Scorecard | + `gap_explorer`, `plan_verifier` |
| Briefing recommended | `ci_maintainer`, `security_auditor` |

Dispatch `gap_explorer` after PyYAML unblocks ingest; union scorecard agents into briefing heap API.

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781218298082.md`
