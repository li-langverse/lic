# Orchestrator note — api-coverage (swarm_coverage)

**Date:** 2026-06-04  
**Worker:** `4d4f1846`  
**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**north_star_fit:** ecosystem, ai — proof-before-perf; orchestration only (no product code in lic)

## Summary

Repaired `swarm-gap-ingest.py` verticals fallback (L229 syntax), installed `python3-yaml`, ran ingest + apply. Refreshed ecosystem scorecard with `LI_CURSOR_AGENTS_ROOT=/app`. **62 open gaps** remain; api-coverage lens highlights **Vision-LLM JSON diagnostics** plan_debt, **li-api-kit** org audit 404, and **MCP/control-plane read APIs** missing on degraded hosts.

## Api-coverage findings

| Surface | Status | Evidence |
|---------|--------|----------|
| `lic check --format=json` / `lic diagnose` | partial (master plan) | `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-` |
| Org repo `li-api-kit` | audit incomplete (HTTP 404) | `benchmarks/data/latest/org-repo-ci-audit.json` |
| Agent briefing MCP | fixture path missing in container | prior `get_briefing_snapshot` ENOENT |
| Control-plane observer API | no disk cache | `ENOENT` `/app/data/control-plane/latest-report.json` |
| Swarm gap registry read | YAML on disk OK | `lic/data/swarm-gap-registry/registry.yaml` (92 rows post-ingest) |
| CVE catalog API feed | 19 Top25 CWEs missing | `benchmarks/data/latest/security-cwe-feed.json` |

## Gap orchestration (Mode B)

- **Ingest:** `python3 scripts/swarm-gap-ingest.py` — registry 92 gaps; `verticals_stubs: 0` (file at `benchmarks/benchmarks/workloads/competitive/verticals.toml`).
- **Apply:** `python3 scripts/swarm-gap-apply-actions.py` — `open_gaps: 62`; studio-ui backlog skipped (`lic-studio-ui` plan path not mounted).
- **Open orch todos:** `orch-r3-missing-package-sweep`, `orch-r4-ui-ux-signals` — defer until CP persistence + studio path mount.

## Handoffs (existing agent ids only)

1. **`issue_planner`** — Vision-LLM JSON/diagnose API completion issues from master-plan gap.
2. **`ci_maintainer`** — resolve `li-api-kit` / `li-sec-agent` / `token-telemetry-service` 404 or remove from org audit list.
3. **`gap_explorer`** — reconcile 30 `competitor_feature` rows after benchmarks catalog PR stack lands.
4. **`security_auditor`** — map 19 CWE catalog rows (human-gated merge).
5. **`plan_verifier`** — refresh goal-directed snapshot (stale `2026-05-30`).

## Control-plane fixes (li-cursor-agents)

- Persist `data/control-plane/latest-report.json` + `state.json` on supervisor tick exit.
- Bake `python3-yaml` + `BENCHMARKS_COMPETITIVE` env in org-research Job (`scripts/lib/benchmarks-env.sh` defaults).
- Add MCP tools: `read_ecosystem_quality_report`, `read_swarm_gap_registry` (reduces ENOENT in meta audits).

## Human-only

- Merge benchmarks PH-5b catalog PR stack (#345–#352) — governance / CI wave.
- CVE catalog row additions — security governance.
- Do **not** add new lic systemd plan loops; route via `config/research-goals.yaml` / `implement-goals.yaml`.

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/app/data/runs/swarm_observer-1780595203173.md`
