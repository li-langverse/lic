# Swarm observer report — `orch-r0-ingest-snapshot`

> `swarm_observer` · research goal `swarm_coverage` · 2026-05-25

## Executive summary

**Posture: degraded.** Ecosystem quality grade **D** (62.4); swarm cannot run fully unattended (`unattended_safe: false`). Goal-directed plan loops are active and healthy (8 runners, 0 stopped). Gap orchestration pipeline is operational: ingest and apply-actions both succeeded this cycle.

## Findings

| Agent / area | Symptom | Evidence | Severity |
|--------------|---------|----------|----------|
| Swarm (SDK) | 78% incomplete runs; 80 still `running` | `benchmarks/data/latest/ecosystem-quality-report.json` → `swarm_execution` | medium |
| `code_implementer` | 4 errors in sample | same report → `top_error_agents` | medium |
| Briefing | 2 preflight failures | `agent-briefing.json` / grade `preflight-failures` | high |
| Ecosystem | 40 PRs failing CI | grade `failed-pr-ci` | high |
| Gap registry | 48 open gaps; studio-ui apply skipped (path) | `data/swarm-gap-registry/registry.yaml`, apply-actions log | medium |
| httpd ingest | Triple-prefix duplicate plan_debt rows | registry `gap-httpd-gap-httpd-gap-*` | low |
| `orch-r0` | Ingest snapshot work item | closed this cycle | — |

## Self-heal actions taken (programmatic + this cycle)

- **Ingest:** Refreshed `registry.yaml` from snapshot + audits (48 gaps).
- **Apply-actions:** Patched package + sim + httpd + security-research backlogs; wrote `benchmarks/data/latest/swarm-gap-actions.json`.
- **Meta:** Closed `gap-plan-pending-swarm-observer-orch-r0-ingest-snapshot`; completed `orch-r0` in `swarm-observer-plan-backlog.md`.
- **Script fix:** `swarm-gap-apply-actions.py` — `security-research` backlog + `STUDIO_UI_UX_PLAN_PATH` for sibling studio plan.

Programmatic observer (supervisor tick) not re-run here; prior cycle auto-retries/healers per briefing signals remain in effect.

## Recommended control-plane fixes

See `docs/ecosystem/orchestrator-notes/2026-05-25-orch-r0-ingest-snapshot.md` — ingest slug dedupe, observer stuck-run policy, refresh ecosystem grade after registry changes.

## Human-only blockers

Failing CI on 64 open PRs, missing CI on 32 repos, governance merges. Confirm `CURSOR_API_KEY` for SDK agents.

## Agent deliverable checklist

- [x] Ingest + apply-actions confirmed
- [x] Orchestrator note + registry reconcile
- [x] Gates: `swarm-observer-plan-gates.sh`
- [x] Branch `cursor/swarm-observer-plan-loop` commit + push
- [x] PR: https://github.com/li-langverse/lic/pull/314

**Orchestrator note:** [2026-05-25-orch-r0-ingest-snapshot.md](../docs/ecosystem/orchestrator-notes/2026-05-25-orch-r0-ingest-snapshot.md)
