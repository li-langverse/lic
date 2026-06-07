# Orchestrator note — orch-r8 security gap handoffs

**Date:** 2026-06-07  
**Worker:** `5b43817d`  
**Goal:** `swarm_coverage` (dimension: **security**)  
**north_star_fit:** ecosystem + ai — secure pillar; proof-before-perf on tier5 exploit gates

## Context

Swarm observer pass reconciled open security-related rows in `lic/data/swarm-gap-registry/registry.yaml` against `benchmarks/data/latest/swarm-gap-actions.json` and briefing signals.

**Evidence:**

- `/workspace/benchmarks/data/latest/security-cwe-feed.json` — 19/25 Top-25 CWEs missing from `lic/security/cve-catalog.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json` — `recommended_agents` includes `security_auditor`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md` — `sec-r1`..`sec-r3` pending
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` — grade **D**, `unattended_safe=false`

## Open security gaps (reconcile)

| gap_id | kind | handoff | action |
|--------|------|---------|--------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | plan_debt | `security_auditor` | Enqueue via `offensive_security` goal; httpd fuzz smoke study |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | plan_debt | `security_auditor` | Tier5 exploit row closure (CWE-20 class); no auto-merge governance |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | plan_debt | `security_auditor` | Runtime surface audit doc under `docs/security/studies/` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | plan_debt | `issue_planner` | Deferred — no ph-db backlog mapping in apply pipeline |
| `gap-line-profiler-001` | missing_package | `issue_planner` | Not security-critical; keep in package backlog |

## Control-plane blockers (this cycle)

1. **PyYAML missing** — `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` cannot run end-to-end. Syntax error at L229 **fixed** locally (`Path(...) / "verticals.toml"`).
2. **CURSOR_API_KEY unset** — programmatic observer cannot SDK-heal leaf agents.
3. **Goal-directed snapshot stale** (2026-05-30) — 6/9 runners stopped; security-research runner state may not reflect live swarm lane.

## Handoff routing (swarm goals — no new systemd loops)

| Target | Mechanism | Notes |
|--------|-----------|-------|
| `security_auditor` | `offensive_security` research goal (`config/research-goals.yaml`) | `sec-r1` httpd fuzz smoke first |
| `gap_explorer` | `ecosystem_gaps` goal | After ingest unblocked — refresh registry from verticals |
| `plan_verifier` | briefing preflight | Re-enable `plan_audit` (currently `--skip-slow`) |
| `pr_merger` | merge queue | lip#52 deploy-pages bump — safe dep, not security |

## orch-r3 / orch-r4 status

- **orch-r3** (`missing-package-sweep`): open in registry; only `gap-line-profiler-001` remains open in `missing_package` kind.
- **orch-r4** (`ui-ux-signals`): open; studio-ui-ux todos not security scope — defer to `gui_ux_tester` / `ui_ux_quality` goal.

## Next observer dispatch order

`pr_merger` (lip#52) → `security_auditor` (`sec-r1`) → `ci_maintainer` → `gap_explorer` (post-PyYAML)
