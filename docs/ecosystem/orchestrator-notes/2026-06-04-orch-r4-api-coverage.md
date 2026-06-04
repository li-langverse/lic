# Orchestrator note — `orch-r4-api-coverage`

**Date:** 2026-06-04  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage@api-coverage` (north_star_fit: ecosystem, ai)  
**Worker:** `535e4de9`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (67.8); `unattended_safe: false` |
| Gap registry | **92** rows after ingest; **62** open (`missing_package` 1, `plan_debt` 31, `competitor_feature` 30) |
| API-coverage lens | Control-plane MCP + gap-ingest **env API** gaps block unattended gap reconcile |
| `orch-r4` (registry) | Still **open** as `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — this run covers **api-coverage** sibling dimension |
| Programmatic prep | Ingest syntax + `BENCHMARKS_COMPETITIVE` fallback fixed; apply refreshed `swarm-gap-actions.json` |

---

## API surface audit (api-coverage dimension)

| Surface | Status | Evidence | Handoff |
|---------|--------|----------|---------|
| `lic check --format=json` / `lic diagnose` | partial (master plan) | `gap-plan-debt-lic-master-plan-vision-llm-*` | `plan_verifier`, `issue_planner` |
| `std.*` modules (io/csv/summary/plot) | io/csv present; summary/plot closed in registry | `ecosystem-explorer.json` | `package_architect` |
| `li-line-profiler` | open seed | `gap-line-profiler-001` → `pkg-line-profiler` | `issue_planner` |
| Swarm-gap ingest env | fixed this run | `scripts/swarm-gap-ingest.py` — `BENCHMARKS_COMPETITIVE` default | merge to `lic` main |
| `verticals.toml` on benchmarks main | missing / worktree-only | `gap-infra-verticals-toml-missing-benchmarks-main` | `gap_explorer`, `docs_maintainer` |
| MCP `li-control-plane-db` | Postgres socket refused in Job | `ECONNREFUSED 127.0.0.1:54322` | `li-cursor-agents` — PostgREST fallback |
| Ecosystem MCP reads | not exposed | prior audits recommend `read_ecosystem_quality_report` | `li-cursor-agents` |
| Org preflight APIs | 2 failures | `org_ci_audit` (li-sec-agent 404), `org_agent_kit_audit` (roadmap missing) | `ci_maintainer`, human |

---

## Gap reconcile (api-coverage priority)

1. **`gap-line-profiler-001`** — only open `missing_package`; patch applied → `ecosystem-package-backlog.md` (`pkg-line-profiler`). Route via `issue_planner` (PH-7e profiling API for agent loops).
2. **Master-plan partial APIs (2e/2f/7d/7e/Vision-LLM)** — deferred in apply (`no runner backlog mapping`); keep on `plan_verifier` + lic master-plan issues, not new swarm loops.
3. **`gap-infra-verticals-toml-missing-benchmarks-main`** — blocks vertical stub ingest API; handoff `gap_explorer` to land `benchmarks/competitive/verticals.toml` on main.
4. **Sim numerics API** (`sim-p1-num-dot-axpy`, `sim-p1-md-neighbor-cell`, `sim-p2-qm-dft-scf`) — patched to `sim-algorithm-backlog.md`; handoff `numerics_researcher` / `code_implementer` via `md_sim_algorithms` / `chem_sim_algorithms` goals.

Do **not** recommend `install-goal-plan-loop-systemd.sh`. Route via `config/research-goals.yaml` (`swarm_coverage`, `ecosystem_gaps`, vertical numerics goals).

---

## Handoffs (cite north_star_fit)

| Target agent | Reason |
|--------------|--------|
| `issue_planner` | `pkg-line-profiler`, Vision-LLM JSON diagnostics issues |
| `gap_explorer` | verticals.toml on main; competitor HPC API stubs |
| `plan_verifier` | refresh plan audit preflight (skipped `--skip-slow`) |
| `ci_maintainer` | 1 repo missing CI; `li-sec-agent` org audit 404 |
| `security_auditor` | 19 Top25 CWEs missing in catalog (briefing P0) |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780539129775.md` (full meta audit)
