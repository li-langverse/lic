# Orchestrator note — orch-r8 api-coverage (swarm_coverage)

**Date:** 2026-06-08  
**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `69b99054`  
**Run:** `swarm_observer-1780891748252`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai

## Summary

Api-coverage lens on the gap orchestration pipeline: registry YAML I/O, ingest/apply scripts, control-plane MCP read paths, and org-research worker filesystem mounts. **64 open registry rows** remain; live ingest/apply is blocked by a **SyntaxError** in `swarm-gap-ingest.py:229` and missing **PyYAML** in the org-research container.

## Api-coverage matrix

| Surface | Expected consumer | Status | Evidence |
|---------|-------------------|--------|----------|
| `lic/data/swarm-gap-registry/registry.yaml` | ingest + apply + observer | **blocked** (PyYAML) | `swarm-gap-apply-actions: PyYAML required` |
| `lic/scripts/swarm-gap-ingest.py` | supervisor tick, observer Mode B | **blocked** (syntax) | `SyntaxError: unterminated string literal` line 229 — **remediated this run** |
| `benchmarks/data/latest/swarm-gap-actions.json` | dashboard, `gap_explorer` | **stale** (2026-05-31) | 64 open; 43 patched/deferred rows unchanged |
| `benchmarks/data/latest/ecosystem-quality-report.json` | observer, grader dispatch | **refreshed** (2026-06-08) | score 65.3, grade D, `unattended_safe=false` |
| `data/control-plane/state.json` | programmatic observer | **missing** | ENOENT under `/app/data/control-plane/` |
| `data/control-plane/latest-report.json` | observer checklist | **missing** | supervisor bootstrap pending |
| `data/runs/*.json` | grader `swarm_execution` | **path mismatch** | grader uses `/workspace/li-cursor-agents/data/runs`; org-research writes `/app/data/runs` → `runs_sampled=0` |
| `lis` registry MCP stub (PR #41) | agent-first capabilities API | **CI fail** | briefing `failed_prs` |

## Open gap reconcile (api-coverage routing)

| gap_kind | open (registry snapshot) | Primary discoverer | Handoff / backlog |
|----------|--------------------------|--------------------|-------------------|
| `competitor_feature` | 30 | `gap_explorer` | `numerics_researcher` + sim backlogs; refresh `verticals.toml` stubs after ingest fix |
| `plan_debt` | 31 | `plan_verifier`, `implementation_gaps` | sim/httpd/studio-ui backlogs; `ph-db` wp-d-registry-v2 unmapped |
| `missing_package` | 3 | `gap_explorer` | `ecosystem-package-backlog.md` → `issue_planner` |
| `ui_ux` | 0 open in actions file | `gui_ux_tester` | lic#575 / studio-ux-16/17 via `ui_ux_quality` goal |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — route via async swarm goals per `docs/ecosystem/swarm-architecture.md`.

## Actions taken this run

1. Fixed `swarm-gap-ingest.py` Path fallback syntax (line 229).
2. Regenerated ecosystem quality scorecard (`python3 scripts/ecosystem-quality-grade.py` in benchmarks).
3. Authored api-coverage whitepaper staging under `docs/research/swarm_coverage/api-coverage/`.

## Handoffs (cite north_star_fit)

| Agent | Reason |
|-------|--------|
| `gap_explorer` | Reconcile 30 `competitor_feature` stubs after ingest unblocked |
| `plan_verifier` | 31 `plan_debt` rows + refresh plan audit preflight |
| `issue_planner` | 3 `missing_package` → ecosystem-package-backlog |
| `ci_maintainer` | 12 repos missing CI; org_ci_audit exit 1 |
| `security_auditor` | CWE Top-25 delta (19 missing in catalog) |
| `pr_merger` | lip#52 merge queue rank 1 |

## Human-only

- Merge lic PR with ingest fix + this note after CI green.
- Resolve lis#40–42 CI before registry MCP api-coverage work proceeds.
- Bake `python3-yaml` (or PyYAML wheel) into org-research Job image — no pip/apt in current container.
