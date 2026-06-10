# Orchestrator note — API-coverage gap orchestration (`746e2c2c`)

**Date:** 2026-06-10  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `746e2c2c`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **C** (75.6) when `runs_dir` resolves; **D** (66.8) on default grader path |
| Gap prep | **Stale** — ingest/apply blocked (PyYAML); last success @ 03:54Z |
| Open gaps | **62** |
| API coverage | REST swarm endpoints **present**; MCP read tools for scorecard/registry **missing** |
| Unattended? | **Conditional** — `unattended_safe: true` only with correct agents-root detection |

---

## API-coverage reconciliation

Swarm gap orchestration depends on **programmatic read APIs** so meta-agents do not guess filesystem layouts across Job pods.

### Gaps closed this run

| Gap | Fix |
|-----|-----|
| Grader `runs_sampled: 0` when `/app` is agents cwd | `ecosystem-quality-grade.py` auto-detects `/app/data/runs` |

### Gaps still open

| Gap | Owner | Handoff |
|-----|-------|---------|
| MCP `read_ecosystem_quality_report` | `li-cursor-agents` | issue_planner |
| MCP `read_swarm_gap_registry` | `li-cursor-agents` | issue_planner |
| CP disk mirrors (`state.json`, `latest-report.json`) | observer tick | supervisor |
| `python3-yaml` in worker image | deploy | infra |
| `LI_CURSOR_AGENTS_ROOT=/app` env default | k8s Job spec | infra |

### REST surfaces (verified in `src/ops-server.ts` + `src/db-api/index.ts`)

- `GET /api/swarm/health` — live health scan
- `GET /api/report` — hybrid latest report
- `GET /api/goals` — research goals export
- `GET /api/swarm/briefing` — scorecard embed
- `GET /api/runs`, `GET /api/research/runs` — run telemetry

Org-research Jobs often run **without** ops-server; MCP must cover the same artifacts.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (blocked):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

| `gap_kind` | Open | Route |
|------------|------|-------|
| `plan_debt` | 31 | `plan_verifier` + sim/security backlogs |
| `competitor_feature` | 30 | `gap_explorer` → numerics research goals |
| `missing_package` | 1 | `issue_planner` (`li-line-profiler`) |

Do **not** recommend `install-goal-plan-loop-systemd.sh` — use async swarm research lane per `docs/ecosystem/swarm-architecture.md`.

---

## Handoffs (cite north_star_fit)

| To agent | Reason |
|----------|--------|
| `gap_explorer` | 62 open gaps; competitor_feature pressure |
| `plan_verifier` | 31 plan_debt rows; briefing plan_audit skipped |
| `ci_maintainer` | 11 repos missing CI |
| `pr_merger` | `lip#52` gate-ready |
| `issue_planner` | MCP api-coverage tools + PyYAML image |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781073483146.md`
