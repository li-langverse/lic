# Swarm gap orchestration — API coverage audit

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `3ea0ca74`  
**Date:** 2026-06-06  
**north_star_fit:** Agentic ecosystem control plane — domains: ecosystem, ai  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/` (staging only)

---

## Abstract

This pass audits **API surface coverage** for the Li agent swarm gap-orchestration pipeline: MCP tools, briefing/scorecard filesystem paths, org CI audit completeness, and control-plane persistence endpoints. The swarm is **degraded** (grade C, 71.3) primarily due to **missing dependency APIs** (PyYAML), **wrong MCP briefing paths**, and **six phantom org repos** returning HTTP 404 — not SDK auth failure.

---

## Method

1. Read [ecosystem-quality-report.json](/workspace/benchmarks/data/latest/ecosystem-quality-report.json) (regenerated with `LI_CURSOR_AGENTS_ROOT=/app`).
2. Invoke MCP `get_briefing_snapshot` on `li-ecosystem-context`.
3. Compare briefing `recommended_agents` vs `data/runs/` samples.
4. Run `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py`.
5. Cross-check [registry.yaml](/workspace/lic/data/swarm-gap-registry/registry.yaml) open rows vs [swarm-gap-actions.json](/workspace/benchmarks/data/latest/swarm-gap-actions.json).

---

## API coverage matrix

| Surface | Expected | Observed | Gap |
|---------|----------|----------|-----|
| MCP briefing read | `/workspace/benchmarks/data/latest/agent-briefing.json` | `/app/fixtures/e2e-benchmarks/...` | **Broken default path** |
| MCP gap registry | YAML → structured read | Not exposed | **Missing tool** |
| MCP scorecard | JSON read | Not exposed | **Missing tool** |
| Org CI audit | All listed repos reachable | 6× HTTP 404 | **Phantom repos** |
| Gap ingest CLI | PyYAML + valid Python | Syntax fixed; PyYAML missing | **Worker deps** |
| CP observer state | `state.json`, `latest-report.json` | ENOENT | **Offline persistence** |
| Research DB | `research_sessions` table | Prior failures | **Schema drift** (historical) |
| Grader runs sample | `/app/data/runs` | Default `/workspace/li-cursor-agents/...` | **Env default** |

---

## Org repos — API audit incomplete (404)

| Repo | Default branch | Impact |
|------|----------------|--------|
| `li-api-kit` | main | Agent API kit surface unverified |
| `li-research-gateway` | cursor/li-research-r0 | Research HTTP API |
| `li-research-ingest` | cursor/li-research-r0 | Ingest pipeline |
| `li-research-mcp` | cursor/li-research-r0 | MCP server repo |
| `li-sec-agent` | main | Security agent API |
| `token-telemetry-service` | main | Telemetry API |

**Recommendation:** Create repos or remove from org CI manifest until they exist.

---

## Gap registry API (orchestration, not product)

- **62 open gaps** — handoffs documented in [orch-r7 note](/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r7-api-coverage-handoffs.md).
- Apply pipeline last ran 2026-05-31; **stale until PyYAML** unblocks re-ingest.
- Retired systemd plan loops **must not** be reinstalled — use `swarm_coverage` research goal + [research-goals.yaml](/app/config/research-goals.yaml).

---

## Recommendations (priority)

1. **P0:** Fix MCP briefing path; bake PyYAML in org-research image.  
2. **P0:** Add MCP `read_gap_registry` + `read_ecosystem_quality_report`.  
3. **P1:** Persist control-plane observer artifacts offline.  
4. **P1:** Resolve 404 API repos (create or delist).  
5. **P2:** Default grader `LI_CURSOR_AGENTS_ROOT=/app` in container entrypoint.

---

## Evidence index

- Observer digest: `/app/data/runs/swarm_observer-1780763996698.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- Briefing: `/workspace/benchmarks/data/latest/agent-briefing.json`

---

_Staged for promotion to research-findings when repo is mounted._
