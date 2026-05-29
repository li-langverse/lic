# Swarm observer report — `orch-r4-stuck-run-finalize`

> `swarm_observer` · research goal `swarm_coverage` · 2026-05-29T19:10Z

## Executive summary

**Posture: degraded.** Grade **D** (66.3); not unattended-safe. The gap registry pipeline is functioning, but swarm execution reliability is poor due to stuck SDK runs, stale control-plane telemetry, and an idle programmatic observer. Numerics pressure (6 red rows) is correctly prioritized; briefing goal orientation is aligned.

## Findings

| Agent / area | Symptom | Evidence | Severity |
|--------------|---------|----------|----------|
| Swarm SDK | 31 `running` rows in last 24h; many with partial output | MCP `agent_runs` | high |
| Swarm SDK | Error rate dominates: 2598 error / 120 finished (24h) | MCP status aggregate | high |
| Observer | `retry_counts: {}`, no healers dispatched | `control_plane_state` | high |
| Dashboard | Report stale since 2025-05-25, falsely healthy | `control_plane_reports` | high |
| `bench_improver` | SDK error; premature; no bench evidence | `bench_improver-1780079811014.json` | high |
| `code_implementer` | GH API rate limit; httpd branch divergence | `code_implementer-1780081276557.json` | medium |
| `implementation_gaps` | SDK error after 3 tool calls | `implementation_gaps-1780080167544.json` | medium |
| `studio_ui_ux_builder` | Repo routing confusion | `studio_ui_ux_builder-1780081364557.json` | medium |
| Goal runners | 6 stopped: compiler-studio, sim, studio-ui-ux, sim-md-research, sim-chem-research, security-research | `goal-directed-agents/snapshot.json` | high |
| httpd | Active on `gap-phase2-perf-wrk-soak`; registry/snapshot dedupe drift | snapshot + plan-verifier digest | medium |
| Preflight | org_agent_kit_audit + security_cwe_audit failed | `agent-briefing.json` | medium |
| Benchmarks | 6 red tier-1 rows | `ecosystem-audit.json` | high |
| Gaps | 53 open (30 competitor, 20 plan_debt, 3 missing_package) | `swarm-gap-actions.json` | medium |

### Error root-cause taxonomy (sampled)

| Class | Agents | Notes |
|-------|--------|-------|
| SDK premature/error | bench_improver, implementation_gaps, studio_ui_ux_builder, mass 19:02 batch | `SDK run status: error` from cursor-sdk-backend |
| Repo conflict / divergence | code_implementer | Local httpd branch diverged from remote plan-loop |
| External API limit | code_implementer | `agent-repo-workflow prepare` hit GitHub rate limit |
| Prompt / routing gap | studio_ui_ux_builder | Edited lic instead of lic-studio-ui workflow clone |
| Deliverable incomplete | bench_improver, studio_ui_ux_builder | Completion audit: premature, no PR URL |

## Self-heal actions taken

- **Gap ingest:** `registry.yaml` updated 2026-05-29T19:09:42Z.
- **Gap apply:** 21 patches to sim/httpd/package backlogs (`swarm-gap-actions.json`, dry_run=false).
- **Observer scan:** 2026-05-29T19:09:42Z — no retries, no stopped agents.
- **Active lane:** `bench_improver` ×3 running; `httpd` goal runner processing wrk soak todo.
- **Meta audit:** this report dispatched because `swarm_execution` dimension < 75.

## Recommended control-plane fixes

1. **`src/observer/finalize-stuck-runs.ts`** — Mark `running` rows older than SDK timeout as `incomplete` or `error`; surface in `swarm_health`.
2. **Supervisor report writer** — Upsert `control_plane_reports` with current `briefing_hash` each tick (replace 4-day-old row).
3. **Heap queue sync** — Purge or re-key `queued_agent_tasks` when briefing hash changes.
4. **Retry policy** — Auto-retry SDK premature errors (budget 3/agent) before `swarm_degraded`.
5. **`prompts/studio-ui-ux-builder.md`** — Default `workflow_repo: lic-studio-ui`; cite studio-ui-ux plan loop skill.
6. **`lic/scripts/swarm-gap-ingest.py`** — Align httpd `plan_pending` with registry closed status (dedupe bug flagged by plan_verifier).
7. **`config/research-goals.yaml`** — Re-enqueue stopped runners: `sim`, `studio-ui-ux`, `security-research`.

## Human-only blockers

- Provability / `trusted.lean` edits.
- Roadmap governance PR review.
- Bulk PR opening for 129 orphan branches.
- Agent-kit sync merges across 9 repos (review drift diff).

## Agent deliverable checklist

- [x] Ecosystem quality report read (66.3 / D)
- [x] Control-plane DB queried (read-only)
- [x] Goal orientation compared (low drift)
- [x] Error runs sampled and classified
- [x] Gap registry reconciled (53 open, apply confirmed)
- [x] Orchestrator note written
- [ ] Observer code PR (recommended follow-up)

**Orchestrator note:** [2026-05-29-orch-r4-stuck-run-finalize.md](../docs/ecosystem/orchestrator-notes/2026-05-29-orch-r4-stuck-run-finalize.md)
