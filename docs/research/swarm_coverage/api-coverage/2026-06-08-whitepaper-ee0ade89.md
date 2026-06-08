# Swarm gap orchestration API coverage — observer audit

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `ee0ade89`  
**Agent:** `swarm_observer`  
**Generated:** 2026-06-08  
**north_star_fit:** ecosystem, ai  
**Status:** draft (staging — publish to `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/`)

---

## Abstract

Li's async swarm relies on programmatic APIs — control-plane REST endpoints, gap registry ingest/apply scripts, and briefing preflights — to orchestrate 64+ open ecosystem gaps without human intervention. This audit maps API coverage for the `swarm_coverage` goal and identifies three blockers preventing unattended operation: missing PyYAML in the org-research worker image, a syntax defect in `swarm-gap-ingest.py` (remediated), and misaligned run-catalog paths for the ecosystem grader.

---

## 1. Control-plane API surface

The ops server (`li-cursor-agents/src/ops-server.ts`) exposes swarm-health endpoints:

| Endpoint | Purpose | Coverage |
|----------|---------|----------|
| `GET /api/swarm/health` | Observer scan + retry counts | Implemented; needs `state.json` |
| `GET /api/goals` | Research goal rows incl. `swarm_coverage` | Implemented |
| `GET /api/report` | Latest supervisor report | Missing artifact in `/app` layout |
| `GET /api/swarm/briefing` | Preflight snapshot | Reads `/workspace/benchmarks/...` |
| `POST /api/briefing/refresh` | Regenerate briefing | Depends on preflight image deps |

**Finding:** APIs exist but observer inputs are not bootstrapped in the `/app` container layout (`runs_sampled: 0`).

---

## 2. Gap registry programmatic API

| Script | Role | 2026-06-08 status |
|--------|------|-------------------|
| `swarm-gap-ingest.py` | YAML registry ← audits/verticals | SyntaxError fixed; PyYAML missing |
| `swarm-gap-apply-actions.py` | Patch markdown backlogs | PyYAML missing |

Registry: **62 open** gaps. Actions file: **64 open** (last apply 2026-05-31).

**Recommendation:** Bake `PyYAML` into `li-cursor-agents` org-research image; run ingest+apply on every `swarm_observer` tick.

---

## 3. Briefing / preflight API coverage

| Preflight | Exit | API gap |
|-----------|------|---------|
| `ecosystem_audit` | 0 | OK |
| `org_ci_audit` | 1 | 12 repos 404 — blocks CI API parity |
| `org_agent_kit_audit` | 1 | `roadmap/agent-kit` not mounted |
| `plan_audit` | skipped | Plan debt API stale |
| `agent_deliverable_gate` | skipped | `LI_CURSOR_AGENTS_ENABLED` unset |

---

## 4. Product API gaps (lis registry stack)

Failed PRs block agent-first server APIs:

- **lis#41** — registry capabilities, validate, MCP stub
- **lis#42** — liserver edge PUT smoke
- **lis#40** — edge-lis-apply for httpd staging

Handoff: `code_implementer` under `server_platform` goal after CI green.

---

## 5. Scorecard

| Metric | Value |
|--------|-------|
| Overall | 66.3 (D) |
| `unattended_safe` | false |
| `gap_pressure` | 60 |
| `swarm_execution` | 65 (0 runs) |

Source: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`

---

## 6. Conclusion

Swarm gap orchestration **APIs are designed but not operable unattended** in the current org-research worker image. Fixing PyYAML, bootstrap state, and `LI_CURSOR_AGENTS_ROOT` unblocks the programmatic observer loop without new agent registry IDs or lic systemd plan loops.

---

## Evidence index

- `data/runs/swarm_observer-1780923260441.md`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r5-api-coverage-handoffs.md`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/data/swarm-gap-registry/registry.yaml`
