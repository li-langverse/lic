# Orchestrator note — API-coverage gap orchestration (`9fc7c786`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `9fc7c786`  
**Run:** `1781145706866`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (75.6), `unattended_safe: true` conditional |
| Gap prep | **Ingest blocked** (PyYAML); apply artifact @ `00:05:46Z` (stale ~3h) |
| Open gaps | **62** (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1) |
| API coverage | REST endpoints OK when ops-server runs; MCP quality/gap tools **missing**; CP disk mirrors **absent** |
| Observer self-heal | **None observable** — `state.json` / `latest-report.json` ENOENT |
| SDK | `CURSOR_API_KEY` set |

---

## API-coverage reconciliation

Swarm gap orchestration requires **read APIs** that work in homelab, K8s org-research Jobs, and CI without pod-specific path knowledge.

### Verified REST (when ops-server running)

| Endpoint | Observer use |
|----------|--------------|
| `GET /api/swarm/health` | Live health scan + retry counts |
| `GET /api/report` | `swarm_health`, interventions, recent runs |
| `GET /api/swarm/briefing` | Scorecard embed |
| `GET /api/goals` | Research goal routing |
| `GET /api/runs` | Error classification |
| `GET /api/interventions` | Self-heal audit |

Org-research Jobs run **without** ops-server — MCP must expose equivalent artifacts.

### MCP gaps (`li-ecosystem-context`)

| Tool | Status |
|------|--------|
| `get_briefing_snapshot` | Works when `BENCHMARKS_ROOT=/workspace/benchmarks`; defaults to fixture path when unset |
| `read_ecosystem_quality_report` | **missing** |
| `read_swarm_gap_registry` | **missing** |
| `list_pending_handoffs` | ok |

### Infra CLI API dependency

```
ModuleNotFoundError: No module named 'yaml'
swarm-gap-ingest: PyYAML required (pip install pyyaml)
```

Treat as deploy contract: bake `python3-yaml` in org-research worker image.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

Last apply: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (19+ backlog patches).

| `gap_kind` | Open | Route |
|------------|------|-------|
| `plan_debt` | 31 | `plan_verifier` + sim/security backlogs (patched rows await research/implement) |
| `competitor_feature` | 30 | `gap_explorer` → numerics research goals |
| `missing_package` | 1 | `issue_planner` (`li-line-profiler`) |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — async swarm research lane per `docs/ecosystem/swarm-architecture.md`.

### Rows reconciled this pass

| Gap id | Action |
|--------|--------|
| `gap-line-profiler-001` | Confirm handoff `issue_planner`; close when package issue filed |
| `orch-r3-missing-package-sweep` | Covered by `gap-line-profiler-001` |
| `orch-r4-ui-ux-signals` | Handoff `ui_ux_quality` → `gui_ux_tester` |
| `gap-infra-verticals-toml-missing-benchmarks-main` | `gap_explorer` + `docs_maintainer` — land `verticals.toml` on benchmarks main |
| Master-plan `plan_debt` (9 rows) | Deferred — no runner backlog mapping |
| ph-db `wp-*` (9) | Route `database_platform` research goal — apply deferred |
| `studio-ux-16/17` | Defer until `STUDIO_UI_UX_PLAN_PATH` set |

---

## Briefing vs scorecard drift

| Source | Top agents |
|--------|------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

**Fix:** Union scorecard recommendations into `recommended_agents` and `heap_plan` via briefing enrichment pipeline.

---

## Handoffs (cite north_star_fit: ecosystem, ai)

| To agent | Reason |
|----------|--------|
| `gap_explorer` | 62 open gaps; `gap_pressure` score 60 |
| `plan_verifier` | 31 plan_debt; `plan_audit` preflight skipped |
| `ci_maintainer` | 27 repos missing CI on main |
| `security_auditor` | Top-25 CWE catalog gaps (19 missing) |
| `issue_planner` | MCP api-coverage tools + PyYAML image + `li-line-profiler` seed |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781145706866.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-11-whitepaper-9fc7c786.md`
