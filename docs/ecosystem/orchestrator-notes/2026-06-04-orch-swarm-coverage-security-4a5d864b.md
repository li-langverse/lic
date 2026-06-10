# Orchestrator note — swarm_coverage × security

**Date:** 2026-06-04  
**Todo:** `orch-swarm-coverage-security` (research worker `4a5d864b`)  
**Goal:** `swarm_coverage`  
**Agent run:** `swarm_observer-1780608089253` (li-cursor-agents control plane)

## Context

Meta-audit under research dimension **security**: reconcile swarm-gap registry security rows with briefing signals (Top25 catalog, httpd/tier5 CI, security-research backlog).

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` — grade **D**, `unattended_safe: false`
- `/workspace/benchmarks/data/latest/agent-briefing.json` — `security_auditor` recommended; 34 failed PRs
- `/workspace/lic/data/swarm-gap-registry/registry.yaml` — open `sec-r1`–`sec-r3` plan_debt rows
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json` — patches to `security-research-backlog.md` (2026-05-31)
- `/workspace/lic/docs/ecosystem/security-research-backlog.md` — `sec-r1`–`sec-r3` **pending**
- `/workspace/lic/data/goal-directed-agents/snapshot.json` — `security-research` runner **stopped**, supervisor off

## Actions taken

1. Regenerated ecosystem quality scorecard (`python3 scripts/ecosystem-quality-grade.py` in benchmarks).
2. Fixed **SyntaxError** in `lic/scripts/swarm-gap-ingest.py` line 229 (`verticals.toml` fallback path).
3. Attempted ingest/apply — blocked by missing **PyYAML** in container (no pip).

## Reconcile (security gaps)

| Registry gap | Backlog | Next agent |
|--------------|---------|------------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | `security_auditor` (`offensive_security`) |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | `security_auditor` |

**Briefing signal:** Top25 missing in catalog = **19** → handoff `issue_planner` + catalog honesty work (benchmarks #266).

**Do not** install `install-goal-plan-loop-systemd.sh` for security-research — route via `config/research-goals.yaml` goal `offensive_security` and async swarm lane.

## Blockers

- PyYAML not in agent runtime → gap ingest/apply cannot refresh until image fix.
- `benchmarks` PRs #351–#358 CI red — tier5 evidence stale for `sec-r2`.
- Snapshot file dated 2026-05-30 — plan_pending counts may lag live runners.

## Follow-up

- [ ] `security_auditor` run on `offensive_security` starting `sec-r1`
- [ ] Close or refresh failing benchmarks metrics PRs before next gap apply
- [ ] Re-run ingest+apply when PyYAML available
- [ ] Publish whitepaper: `docs/research/swarm_coverage/security/2026-06-04-whitepaper.md` → `research-findings`
