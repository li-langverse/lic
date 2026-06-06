# Orchestrator note — swarm_coverage @ api-coverage (2026-06-06)

**Worker:** `bcb35ec7`  
**Run:** `swarm_observer-1780725286338`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai

## Summary

Gap orchestration API path was **blocked** by a regressed syntax error in `lic/scripts/swarm-gap-ingest.py:229` and missing PyYAML in the org-research container. Both were remediated this pass. Ingest + apply succeeded @ `2026-06-06T06:09:13Z`.

## API-coverage audit

| API / script | Status | Notes |
|--------------|--------|-------|
| `get_briefing_snapshot` (MCP) | OK | Returns compact briefing keys |
| `list_pending_handoffs` (MCP) | OK | Empty queue this cycle |
| `ecosystem-quality-grade.py` | OK | Score 73.6 / C after gap refresh |
| `swarm-gap-ingest.py` | **Fixed** | L229 Path fallback for `verticals.toml` |
| `swarm-gap-apply-actions.py` | OK | Requires PyYAML — install in Job image |
| Control-plane observer ingest tick | Partial | `LIC_ROOT=/workspace/lic` set; no CP state mirror |
| `agent_deliverable_gate` | Disabled | `LI_CURSOR_AGENTS_ENABLED=0` |
| Whitepaper publish API | Blocked | `research-findings` not mounted |

## Gap reconcile (62 open)

| Kind | Count | Action |
|------|-------|--------|
| `missing_package` | 1 | `gap-line-profiler-001` → `issue_planner` |
| `plan_debt` | 31 | sim/security backlogs patched; master-plan rows deferred |
| `competitor_feature` | 30 | vertical stubs → `sim-md-research-backlog.md` |
| `ui_ux` | 0 open | studio apply skipped — `lic-studio-ui` path missing |

## Handoffs

1. **`gap_explorer`** — registry hygiene after benchmarks catalog CI (#354 stack)  
2. **`ci_maintainer`** — 3 repos missing CI; unblock metrics PRs  
3. **`security_auditor`** — CWE Top25 catalog + `sec-r1`–`sec-r3`  
4. **`plan_verifier`** — enable `plan_audit` preflight

Do **not** add lic systemd plan loops.

## Evidence

- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780725286338.md`
