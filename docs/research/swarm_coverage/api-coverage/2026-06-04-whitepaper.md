# Swarm coverage — api-coverage dimension

**Goal:** `swarm_coverage`  
**Worker:** `4d4f1846`  
**Generated:** 2026-06-04T18:29Z  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/` (deferred — repo not mounted)

## Abstract

This pass audits **API and agent-facing surfaces** for the Li swarm control plane: compiler JSON diagnostics (Vision-LLM), org repo API kit visibility, briefing/MCP read paths, and gap-registry orchestration APIs. The swarm is **degraded** for unattended operation (`unattended_safe: false`, grade **C**, score **73.6**) primarily due to CI/PR posture and stale goal-directed snapshot, not SDK auth.

## Api-coverage matrix

| API / surface | Consumer | Coverage | Gap id / note |
|---------------|----------|----------|---------------|
| `lic check --format=json` | agents, CI | partial | `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-` |
| `lic diagnose` | agents | partial | same |
| `agent-briefing.json` | supervisor preflight | present | `/workspace/benchmarks/data/latest/agent-briefing.json` |
| `ecosystem-quality-report.json` | swarm_observer, dashboard | present (refreshed) | score 73.6 |
| `swarm-gap-registry` | gap_explorer, swarm_observer | present | 62 open after apply |
| Org `li-api-kit` GitHub API | ci_maintainer audit | **missing** | HTTP 404 — incomplete audit |
| Control-plane `latest-report.json` | programmatic observer | **missing** | ENOENT on host |
| MCP `li-control-plane-db` | meta agents | down | ECONNREFUSED :54322 |
| CVE catalog ↔ Top25 feed | security_auditor | **19 gaps** | `security-cwe-feed.json` |

## Orchestration health

- **Briefing vs heap:** compact briefing recommends `ci_maintainer` + `security_auditor`; scorecard adds `gap_explorer` + `plan_verifier` — partial drift, security P0 still covered.
- **Gap pipeline:** ingest/apply green after L229 fix + PyYAML; studio-ui patches skipped (path mount).
- **Runs sample:** 1 run in `/app/data/runs` (this pass); grader `swarm_execution` = 100 only because sample size is 1.

## Recommendations (proof → easy → fast)

1. Ship Vision-LLM JSON/diagnose APIs before expanding agent automation (proof-gated issues).
2. Fix or delist 404 org repos so CI audit APIs return complete graphs.
3. Persist control-plane JSON artifacts so observer retries/healers are observable without Supabase.
4. Unblock benchmarks catalog PRs so competitive `verticals.toml` ingest adds stub rows on main.

## References

- `docs/ecosystem/swarm-architecture.md`
- `config/research-goals.yaml` — `swarm_coverage`
- Orchestrator note: `docs/ecosystem/orchestrator-notes/2026-06-04-orch-api-coverage-4d4f1846.md`
