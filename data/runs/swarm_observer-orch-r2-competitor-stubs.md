# Swarm observer report — `orch-r2-competitor-stubs`

> `swarm_observer` · research goal `swarm_coverage` · 2026-05-29 · run `swarm_observer-1780081384484`

## Executive summary

- **Posture: degraded / critical execution.** Ecosystem grade **D** (64.8); `unattended_safe: false`.
- **Swarm execution:** 117 runs stuck `running`; 33% error rate on last 3 terminal runs; 2599 errors in 24h DB window.
- **Goal-directed:** 6/8 runners stopped; `agents_live: 0` per snapshot (2026-05-29T19:05Z).
- **Gap orchestration (orch-r2): complete** — 30 open `competitor_feature` rows; 12 vertical stubs ingested; 12 backlog todos patched.
- **Briefing alignment:** Heap prioritizes PR/numerics/governance; 14 recommended agents match active dispatch (proof_gap, bench_improver, plan_verifier, etc.).
- **Preflight:** 1 failure (`org_agent_kit_audit` exit 1); 8 scripts skipped (`--skip-slow`).
- **Benchmarks:** 6 red tier-1 rows (matmul, ML, gmres) — handoff to `numerics_researcher` / `bench_improver`.
- **Unattended safe:** **No** — requires stuck-run sweep + preflight un-skip before routine updates.

## Findings

| Agent / area | Symptom | Evidence | Severity |
|--------------|---------|----------|----------|
| Swarm SDK | 117 runs `running` (stuck) | `li-cursor-agents/data/runs`, ecosystem-quality-report | critical |
| Swarm SDK | 33% error / incomplete on terminal sample | `benchmarks/data/latest/ecosystem-quality-report.json` | critical |
| `code_implementer` | Post-run gates exit 1 streak | `code_implementer-1780080996324.json` | high |
| Goal-directed | 6 runners stopped | `lic/data/goal-directed-agents/snapshot.json` | high |
| Briefing | `org_agent_kit_audit` preflight fail | `benchmarks/data/latest/agent-briefing.json` | medium |
| Briefing | 8 preflight scripts skipped | agent-briefing `preflight_runs` | medium |
| Benchmarks | 6 red rows | agent-briefing `ecosystem_audit.benchmarks.red` | high |
| Gap registry | 54 open gaps (30 competitor) | `lic/data/swarm-gap-registry/registry.yaml` | low |
| Infra | `verticals.toml` not on benchmarks main | `gap-infra-verticals-toml-missing-benchmarks-main` | medium |
| Workspace | 2 dirty sibling repos | agent-briefing `workspace_dirty_sweep` | low |

## Self-heal actions taken

Programmatic observer (this cycle):

- Last scan: `control_plane_state.observer.last_scan_at` = 2026-05-29T19:03:31Z
- `retry_counts`: empty — no auto-retries dispatched
- `stopped_agents`: none

Meta-audit (this run):

- Regenerated `ecosystem-quality-report.json` (stale from 2026-05-27)
- Ran `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py`
- Patched 12 competitor vertical stubs into sim backlogs
- Closed registry row `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs`

## Recommended control-plane fixes

| Fix | Path |
|-----|------|
| Finalize stuck `running` runs after SDK timeout | `li-cursor-agents/src/control-plane/finalize-run.ts` |
| Lower parallel pool cap when error streak > N | `li-cursor-agents/src/control-plane/parallel-pool.ts` |
| Un-skip slow preflights on supervisor tick (plan audit, ci triage) | briefing generator flags |
| Add `competitor_feature` default loop for benchmark-red gaps → `sim` or research goal | `lic/scripts/swarm-gap-apply-actions.py` |
| Route CAE stubs via ingest `suggested_loop` by vertical family | `lic/scripts/swarm-gap-ingest.py` |

## Human-only blockers

- Merge `benchmarks/competitive/verticals.toml` to benchmarks main
- Governance PRs touching `trusted.lean` / master-plan phases
- `CURSOR_API_KEY` present — SDK auth OK this host

## Agent deliverable checklist

- [x] Ingest + apply-actions
- [x] Orchestrator note: `docs/ecosystem/orchestrator-notes/2026-05-29-orch-r2-competitor-stubs.md`
- [x] Registry orch-r2 closed; backlog orch-r2 completed
- [x] Gates
- [x] Report under `data/runs/`

**Orchestrator note:** [2026-05-29-orch-r2-competitor-stubs.md](../docs/ecosystem/orchestrator-notes/2026-05-29-orch-r2-competitor-stubs.md)

## Recommended issues/PRs

| Title | Repo | Labels |
|-------|------|--------|
| chore(benchmarks): publish competitive/verticals.toml on main | benchmarks | ecosystem, gap-orchestration |
| fix(control-plane): finalize stuck SDK runs after heartbeat timeout | li-cursor-agents | swarm, self-heal |
| research: tier-1 matmul_naive / num_gmres red row plan | lic | numerics, PH-7e, PH-5b |
| chore(lic): merge sim-md-research competitor stub backlog todos | lic | sim, research |

## Deferred

- `orch-r3-missing-package-sweep` — std.summary/plot + line_profiler backlog verify
- `orch-r4-ui-ux-signals` — studio-ui-ux gap taxonomy
- Master-plan `plan_debt` rows (9 deferred — no runner backlog mapping)
- HPC competitor gaps (Kokkos, PETSc, hypre) — research handoffs only, no lic product code
