# Orchestrator note — orch-r8 security gap handoffs

**Date:** 2026-06-07  
**Worker:** `3a064c05`  
**Goal:** `swarm_coverage` (security dimension)  
**north_star_fit:** ecosystem + ai — swarm gap orchestration under secure pillar

## Context

Ecosystem quality grade **D (69.6)**, `unattended_safe=false`. Gap registry has **64 open rows**; security-relevant subset below. Programmatic gap ingest/apply still blocked in worker image (PyYAML missing); ingest **SyntaxError L229** remediated locally this run.

## Security gap reconciliation

| gap_id | kind | status | action |
|--------|------|--------|--------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | plan_debt | open | Handoff `security_auditor` → `offensive_security` goal; link httpd tier5 fuzz harness |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | plan_debt | open | Handoff `security_auditor`; depends on httpd `gap-phase2-mitigation-exploits` (completed in snapshot) |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | plan_debt | open | Handoff `security_auditor` + `code_implementer`; runtime surface audit (lic RT, li-httpd) |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | plan_debt | open | Route via `goal_researcher` / `database_platform` vertical; cross-link ph-db backlog |
| CWE Top25 catalog (19 missing) | — | open | Human-gated `lic/security/cve-catalog.json` backfill; **not** auto-merge |

## Registry apply (blocked)

- `swarm-gap-ingest.py`: fixed Path fallback for `verticals.toml` (local; open PR on lic).
- `swarm-gap-apply-actions.py`: cannot run — `ModuleNotFoundError: yaml`.
- **Do not** recommend `install-goal-plan-loop-systemd.sh`; security work routes through `offensive_security` research goal + swarm agents.

## Handoffs enqueued (goals, not new agent ids)

1. **`security_auditor`** — `offensive_security` goal (priority 9): CWE catalog delta + httpd fuzz smoke (`sec-r1`).
2. **`gap_explorer`** — reconcile 64 open gaps after PyYAML bake + ingest merge.
3. **`plan_verifier`** — refresh goal-directed snapshot (stale 2026-05-30); close `orch-r3`/`orch-r4` when todos complete.
4. **`ci_maintainer`** — 14 repos missing CI; unblocks org_ci_audit preflight.

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml` (sec-r1..r3, wp-n5-security-bench)
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
