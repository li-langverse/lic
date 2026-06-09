# Swarm coverage — api-coverage dimension (2026-06-06)

**Goal id:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `eb17377e`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/`  
**north_star_fit:** ecosystem, ai — provable server/stdlib API surfaces before perf claims

## Abstract

This pass audits swarm gap orchestration through an **api-coverage** lens: whether registry ingest/apply, benchmark catalog charts, org repo CI signals, and MCP briefing paths expose enough API surface for unattended swarm operation. Grade **D (62.6)** with `unattended_safe: false`. Root blockers are infra (gap ingest script, missing CP observer state, phantom org repos), not SDK auth.

## Method

1. Regenerated `ecosystem-quality-report.json` via `benchmarks/scripts/ecosystem-quality-grade.py`.
2. Compared briefing `recommended_agents` vs heap plan (no drift).
3. Ran `lic/scripts/swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` after local fixes.
4. Sampled `dashboard-gap-report.json`, `org-repo-ci-audit.json`, and registry open rows for httpd/stdlib/security API gaps.
5. Probed MCP `get_briefing_snapshot` for agent-facing API completeness.

## Findings

### 1. Gap pipeline API

- Ingest script had a **syntax error** and **KeyError** on `BENCHMARKS_COMPETITIVE`, preventing registry refresh on every supervisor tick.
- Apply requires PyYAML; not baked in worker image by default.
- After fix: **62 open gaps** — api-relevant: Phase H li-httpd, `sec-r1-httpd-fuzz-smoke`, stdlib missing modules.

### 2. Benchmark catalog API coverage

`dashboard-gap-report.json` lists **12 P1 chart_pending** rows:

- **Httpd/server (9):** `https_static`, `keepalive_pipelining`, `lb_least_conn`, `lb_peer_down`, `lb_round_robin`, `proxy_loopback`, `rate_limit_429`, `static_large`, `static_small`
- **Stdlib (3):** `stdlib_binary_search`, `stdlib_dict_insert_lookup`, `stdlib_sort_int`

These are API-surface gaps: charts exist in summary but lack runnable Li workloads — blocks proof-before-perf claims for server/stdlib.

### 3. Org repo API inventory

`org-repo-ci-audit.json` reports **6 incomplete audits (HTTP 404)**:

- `li-api-kit`
- `li-research-gateway`
- `li-research-ingest`
- `li-research-mcp`
- `li-sec-agent`
- `token-telemetry-service`

Briefing inflates `repos_missing_ci_main: 6` from these phantoms — orchestration should distinguish **missing repo** vs **missing workflow**.

### 4. Agent control-plane API

- `data/control-plane/latest-report.json` and `state.json` **absent** in org-research pod → programmatic observer cannot expose retry budget API to meta-agent.
- MCP `get_briefing_snapshot` pointed at `/app/fixtures/e2e-benchmarks/...` instead of `/workspace/benchmarks/data/latest/agent-briefing.json`.
- Ecosystem grader `runs_sampled: 0` because `runs_dir` mount path mismatch.

## Recommendations

| Priority | Action | Owner agent |
|----------|--------|-------------|
| P0 | Merge ingest fix; bake PyYAML in worker | `ci_maintainer` / human |
| P0 | Persist CP observer artifacts offline | control-plane PR |
| P1 | Stub-honest or implement chart_pending httpd/stdlib workloads | `bench_improver`, `stdlib_researcher` |
| P1 | Dispatch `sec-r1-httpd-fuzz-smoke` | `security_auditor` |
| P2 | MCP tools: `read_swarm_gap_registry`, fix briefing path | `li-cursor-agents` |
| P2 | Roadmap: create or delist 404 repos | human + `issue_planner` |

## Conclusion

Swarm gap orchestration **APIs are incomplete** for unattended operation: ingest was broken, observer state is not readable, catalog charts are pending, and org repo audit conflates missing repos with missing CI. Fixing orchestration (not re-running leaf agents blindly) restores api-coverage for the swarm control plane.

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/dashboard-gap-report.json`
- `/workspace/benchmarks/data/latest/org-repo-ci-audit.json`
- `/app/data/runs/swarm_observer-1780753191336.md`
