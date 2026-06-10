# Orchestrator note — API-coverage gap orchestration (`e0f2dd4a`)

**Date:** 2026-06-10  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `e0f2dd4a`  
**Run:** `1781110863279`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (75.6), `unattended_safe: true` conditional |
| Gap prep | **Stale ingest** (PyYAML); **fresh apply artifact** @ 14:45Z |
| Open gaps | **62** (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1) |
| API coverage | REST swarm endpoints **present**; MCP read tools for scorecard/registry **missing** |
| Observer self-heal | **None** — CP disk mirrors absent |

---

## API-coverage reconciliation

Meta-agents auditing swarm health must read scorecards, gap registries, and control-plane state through **stable programmatic APIs**, not pod-specific filesystem paths.

### Verified REST surfaces (`li-cursor-agents`)

- `GET /api/swarm/health` — live health scan
- `GET /api/report` — hybrid latest report
- `GET /api/goals` — research goals export
- `GET /api/swarm/briefing` — scorecard embed
- `GET /api/runs`, `GET /api/research/runs` — run telemetry
- `GET /api/interventions` — healer dispatch log

Org-research Jobs run **without** ops-server — MCP must expose the same artifacts.

### MCP gaps (`li-ecosystem-context`)

| Tool needed | Status |
|-------------|--------|
| `read_ecosystem_quality_report` | **missing** |
| `read_swarm_gap_registry` | **missing** |
| `get_briefing_snapshot` | partial (no quality report / gap actions) |

### Infra API dependency

`swarm-gap-ingest.py` requires PyYAML — blocked in this pod (`ModuleNotFoundError: yaml`). Treat as deploy API contract: bake `python3-yaml` in org-research worker image.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (ingest blocked):
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

Last successful apply artifact: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (19 backlog patches).

| `gap_kind` | Open | Route |
|------------|------|-------|
| `plan_debt` | 31 | `plan_verifier` + sim/security backlogs |
| `competitor_feature` | 30 | `gap_explorer` → numerics research goals |
| `missing_package` | 1 | `issue_planner` (`li-line-profiler`) |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — async swarm research lane per `docs/ecosystem/swarm-architecture.md`.

### Rows needing handoff (no backlog mapping)

- `orch-r3-missing-package-sweep`, `orch-r4-ui-ux-signals` → `issue_planner` / `gui_ux_tester`
- ph-db wp-* (9) → `database_platform` research goal
- studio-ux-16/17 → mount `lic-studio-ui` or `ui_ux_quality` goal

---

## Handoffs (cite north_star_fit: ecosystem, ai)

| To agent | Reason |
|----------|--------|
| `gap_explorer` | 62 open gaps; scorecard `gap_pressure` 60 |
| `plan_verifier` | 31 plan_debt; plan_audit preflight skipped |
| `ci_maintainer` | 28 repos missing CI on main |
| `security_auditor` | Top-25 CWE catalog gaps (19) |
| `issue_planner` | MCP api-coverage tools + PyYAML image |
| `pr_merger` | `lip#52` merge-approved when human gate clears |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (refreshed 18:09Z)
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781110863279.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-10-whitepaper-e0f2dd4a.md`
