# Swarm observer report — `orch-r3-missing-package-sweep`

> `swarm_observer` · research goal `swarm_coverage` · 2026-05-29 · run `swarm_observer-1780081620079`  
> **north_star_fit:** ecosystem orchestration — PH-IO package gaps (proof → easy → fast)

## Executive summary

- **Posture: degraded.** Ecosystem grade **D** (66.3); `unattended_safe: false`.
- **orch-r3 complete:** `missing_std_modules` reconciled; 3 open `missing_package` registry rows; 5 package backlog todos pending.
- **Swarm execution:** 2925 historical errors in DB; 29 runs still `running`; programmatic observer idle (`retry_counts: {}`).
- **Goal-directed:** 6/8 runners stopped; `agents_live: 0` (`lic/data/goal-directed-agents/snapshot.json`).
- **Briefing alignment:** 14 recommended agents match heap (PR, numerics, governance, ecosystem); `swarm_observer` + `gap_explorer` active for coverage goal.
- **Benchmarks:** 6 red tier-1 rows — `bench_improver` / `numerics_researcher` dispatched.
- **Gap registry:** 53 open (30 competitor, 20 plan_debt, 3 missing_package).
- **Unattended safe:** **No** — stuck-run finalize + preflight un-skip required.

## Findings

| Agent / area | Symptom | Evidence | Severity |
|--------------|---------|----------|----------|
| Swarm SDK | 29+ runs `running` in DB | `agent_runs` status counts | critical |
| Swarm SDK | 2925 `error` rows (lifetime sample) | `li-control-plane-db` `agent_runs` | high |
| `code_implementer` | Latest terminal error in quality sample | `ecosystem-quality-report.json` | medium |
| Goal-directed | 6 runners stopped | `lic/data/goal-directed-agents/snapshot.json` | high |
| PH-IO packages | `std.summary`, `std.plot` missing | `ecosystem-explorer.json` `missing_std_modules` | high |
| Package backlog | 5 pending orchestrator todos | `ecosystem-package-backlog.md` | medium |
| Briefing | `org_agent_kit_audit` preflight fail | `agent-briefing.json` `preflight_runs` | medium |
| Benchmarks | 6 red rows | `agent-briefing.json` `ecosystem_audit.benchmarks.red` | high |
| Control plane report | Stale `is_latest` (2026-05-25, healthy=true) | `control_plane_reports` | medium |
| Workspace | 2 dirty sibling repos | `workspace_dirty_sweep` | low |

## Self-heal actions taken

**Programmatic observer (2026-05-29T19:05Z):**

- `observer.retry_counts`: empty — no auto-retries
- `stopped_agents`: none
- Last scan: 2026-05-29T19:05:31Z

**Meta-audit (this run):**

- Regenerated `ecosystem-quality-report.json` (score 64.8 → 66.3)
- Ran `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py`
- Verified 3 `missing_package` patches → `ecosystem-package-backlog.md`
- Closed `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep`

## Recommended control-plane fixes

| Fix | Path |
|-----|------|
| Finalize stuck `running` runs after SDK timeout | `li-cursor-agents/src/control-plane/finalize-run.ts` |
| Refresh `control_plane_reports.is_latest` each supervisor tick | briefing / report writer |
| Auto-close `pkg-std-io`/`pkg-std-csv` when explorer status=present + issue filed | `swarm-gap-apply-actions.py` |
| Un-skip slow preflights (`plan_audit`, `ci_bug_triage`) | briefing generator |
| Route `missing_package` handoffs to `issue_planner` in heap when open_gaps > 0 | `heap-coordinator` |

## Human-only blockers

- Implement `std.summary` / `std.plot` (product — `package_architect`)
- Governance / `trusted.lean` PRs
- `CURSOR_API_KEY` — present on host; SDK auth OK

## Agent deliverable checklist

- [x] Ingest + apply-actions
- [x] Orchestrator note: `docs/ecosystem/orchestrator-notes/2026-05-29-orch-r3-missing-package-sweep.md`
- [x] Registry orch-r3 closed; backlog orch-r3 completed
- [x] Report under `data/runs/`
- [ ] Gates (run on commit branch)

**Orchestrator note:** [2026-05-29-orch-r3-missing-package-sweep.md](../docs/ecosystem/orchestrator-notes/2026-05-29-orch-r3-missing-package-sweep.md)

## Recommended issues/PRs

| Title | Repo | Labels |
|-------|------|--------|
| feat(std): PH-IO-7 `std.summary` for benchmark ingest | lic | PH-IO-7, ecosystem |
| feat(std): PH-IO-5 `std.plot` static dashboard hooks | lic | PH-IO-5, ecosystem |
| chore(ecosystem): seed `li-line-profiler` package issue | lic | profiling, gap-orchestration |
| fix(control-plane): finalize stuck SDK runs after heartbeat timeout | li-cursor-agents | swarm, self-heal |
| chore(lic): close pkg-std-io/pkg-std-csv backlog when PH-IO issues exist | lic | ecosystem |

## Deferred

- `orch-r4-ui-ux-signals` — studio-ui-ux gap taxonomy
- Master-plan `plan_debt` rows without runner backlog mapping (9+ deferred)
- HPC `competitor_feature` gaps — research handoffs only
