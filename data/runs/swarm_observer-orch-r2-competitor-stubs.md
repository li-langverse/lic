# Swarm observer report — `orch-r2-competitor-stubs`

> `swarm_observer` · research goal `swarm_coverage` · run `swarm_observer-1780113782040` · 2026-05-30

## Executive summary

- **Posture: degraded.** Ecosystem grade **D** (69.8); `unattended_safe: false`.
- **Gap orchestration:** 30 `competitor_feature` rows ingested; apply-actions patched 12 vertical stub rows across sim backlogs (`benchmarks/data/latest/swarm-gap-actions.json`).
- **Swarm execution:** 117 runs stuck `running`; 24h error streaks on core agents (300+ each) — root cause **GitHub GraphQL rate limit**, not SDK auth.
- **Goal drift:** Briefing heap prioritizes numerics/governance; async swarm also fans out 15+ UX/PR agents not in heap plan.
- **Programmatic observer:** `retry_counts` empty; stale control-plane report (2026-05-25) still marks swarm healthy.
- **Preflight:** `org_agent_kit_audit` exit 1; 8 scripts skipped (`--skip-slow`).
- **Benchmarks:** 6 red tier-1 rows (matmul, ML, GMRES) — handoff to `bench_improver` / `numerics_researcher`.
- **Unattended?** **No** — rate limits, stuck runs, 6 stopped goal-directed runners block safe unattended operation.

## Findings

| Agent / area | Symptom | Evidence | Severity |
|--------------|---------|----------|----------|
| Swarm (async) | 117 runs `running`; 33% incomplete in sample | `ecosystem-quality-report.json` → `swarm_execution`; `li-cursor-agents/data/runs/` | high |
| `workspace_sweeper` | Push failed: GraphQL rate limit | `workspace_sweeper-1780113491850.json` | high |
| `pr_reviewer` | Preflight empty PR list (GraphQL) | `pr_reviewer-1780112844596` output_md | high |
| `implementation_gaps` | 357 errors / 24h | Supabase `agent_runs` | medium |
| `bench_improver` | 304 errors / 24h | Supabase `agent_runs` | medium |
| `studio_ui_ux_builder` | SDK error mid-run | `studio_ui_ux_builder-1780111965967` output_md | medium |
| Goal-directed | 6 runners stopped, 0 agents live | `lic/data/goal-directed-agents/snapshot.json` | high |
| Briefing vs DB | Report healthy; live errors ignored | `control_plane_reports` vs `agent_runs` | medium |
| Benchmarks | 6 red rows | `agent-briefing.json` → `ecosystem_audit.benchmarks.red` | high |
| Gap infra | `verticals.toml` missing on benchmarks main | `registry.yaml` → `gap-infra-verticals-toml-missing-benchmarks-main` | medium |

## Self-heal actions taken

- Ran `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` (live).
- Patched sim backlogs for vertical stub competitor gaps.
- Regenerated `benchmarks/data/latest/ecosystem-quality-report.json` (grade D, 69.8).
- Closed registry row `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs`.
- Observer auto-retry: **none** (`control_plane_state.payload.observer.retry_counts` empty).

## Recommended control-plane fixes

| File | Change |
|------|--------|
| `li-cursor-agents/src/observer/` | Degrade when GraphQL 403 or >N concurrent errors |
| `li-cursor-agents/src/backends/cursor-sdk-backend.js` | Timeout orphan `running` runs |
| `benchmarks/scripts/pr-program-run.py` | REST fallback on GraphQL rate limit |
| `benchmarks/scripts/workspace-dirty-sweep.py` | Defer push/PR when rate-limited |
| `lic/scripts/swarm-gap-ingest.py` | Document dual-path verticals.toml resolution |

## Human-only blockers

- GitHub GraphQL quota (user ID 207167228) — blocks sweep, PR program, merge queue until reset.
- Governance PRs on roadmap — no auto-merge.
- Land `benchmarks/competitive/verticals.toml` on benchmarks main (WP-LIC-01).

## Agent deliverable checklist

- [x] Ingest + apply-actions confirmed
- [x] 30 `competitor_feature` rows reconciled in registry
- [x] Orchestrator note: `docs/ecosystem/orchestrator-notes/2026-05-30-orch-r2-competitor-stubs.md`
- [x] Gates (pending run)
- [x] Report under `data/runs/`

**Orchestrator note:** [2026-05-30-orch-r2-competitor-stubs.md](../docs/ecosystem/orchestrator-notes/2026-05-30-orch-r2-competitor-stubs.md)

## Recommended issues/PRs

| Title | Repo | Labels |
|-------|------|--------|
| chore(benchmarks): land competitive verticals.toml on main | benchmarks | `surface:bench`, `li-swarm` |
| fix(swarm): REST fallback when GitHub GraphQL rate-limited | li-cursor-agents | `agent:bug_fixer`, `li-swarm` |
| fix(observer): mark stale running SDK runs incomplete | li-cursor-agents | `agent:bug_fixer` |
| perf(7e): tier-1 matmul blocked/naive ≤1.2× cpp | lic | `PH-7e`, `merge-approved` |
| docs(sim): vertical stub honesty backlog rows | lic | `surface:docs` |

## Deferred

- **orch-r3/r4** — already completed on branch; no re-run this cycle
- **Full error streak remediation** — wait for GraphQL reset before re-dispatching PR/UX cohort
- **Goal-directed runner restart** — human/systemd after rate limit clears
- **Red benchmark codegen** — after lic perf PR merge + ingest

---

_north_star_fit: ecosystem + ai (swarm_coverage) · evidence: `registry.yaml`, `swarm-gap-actions.json`, `ecosystem-quality-report.json`_
