# Orchestrator note — security gap handoffs (`orch-r5`)

**Date:** 2026-06-07  
**Goal:** `swarm_coverage@security`  
**Agent:** `swarm_observer`  
**north_star_fit:** ecosystem, ai — security lens on swarm gap orchestration

## Context

- Ecosystem quality grade **D (62.4)**, `unattended_safe=false`.
- Gap registry: **64 open** (`swarm-gap-actions.json`); ingest/apply blocked by PyYAML absence.
- `swarm-gap-ingest.py:229` syntax error **fixed** this pass (Path fallback for `verticals.toml`).
- Control-plane `state.json` / `latest-report.json` missing — programmatic heal inactive.

## Security gaps reconciled

| Registry id | Plan todo | Action |
|---|---|---|
| `gap-plan-pending-security-research-sec-r0-cwe-delta` | `sec-r0-cwe-delta` | **Closed** — backlog marks completed; feed sync passes |
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | **Handoff** → `security_auditor` / `offensive_security` goal |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | **Handoff** → `security_auditor` (tier5 exploit rows) |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | **Handoff** → `security_auditor` (runtime surface study) |

## CWE catalog benchmark

- Source: `benchmarks/data/latest/security-cwe-feed.json`
- Catalog: `lic/security/cve-catalog.json` (15 CWE classes)
- **19 Top-25 CWE classes missing** — primary security debt for `security_auditor`
- Do **not** disable provability gates; map new CWE rows to `li-tests/security/` patterns

## Routing (no new loops)

- Use existing `offensive_security` research goal (`config/research-goals.yaml` in li-cursor-agents).
- Do **not** install `security-research` systemd plan loop — migrated to async swarm.
- Product work (httpd fuzz harness, catalog expansion) via `security_auditor` → `code_implementer` handoff only after study deliverable.

## Blockers

1. PyYAML missing in worker — gap ingest/apply cannot run live.
2. `research-findings` repo not mounted — whitepaper publish deferred.
3. GitHub API rate limit blocks `org_ci_audit`.

## Evidence paths

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/security-cwe-feed.json`
- `lic/docs/ecosystem/security-research-backlog.md`
- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `data/runs/swarm_observer-1780828414552.md` (li-cursor-agents)
