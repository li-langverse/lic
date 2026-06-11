# Orchestrator note — API-coverage gap orchestration (`48602cda`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `48602cda`  
**Run:** `1781138502256`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (75.6), `unattended_safe: true` conditional |
| Gap prep | **Ingest blocked** (PyYAML); apply artifact @ `00:05:46Z` |
| Open gaps | **62** (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1) |
| API coverage | REST swarm endpoints present when ops-server runs; MCP quality/gap read tools **missing**; `get_briefing_snapshot` broken in Job pod |
| Observer self-heal | **None observable** — CP `state.json` / `latest-report.json` absent |
| SDK | `CURSOR_API_KEY` set |

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
| `get_briefing_snapshot` | **broken** in this pod (`fixtures/e2e-benchmarks/...`) |

### Infra API dependency

```
ModuleNotFoundError: No module named 'yaml'
swarm-gap-ingest: PyYAML required (pip install pyyaml)
```

Treat as deploy API contract: bake `python3-yaml` in org-research worker image.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

Last apply artifact: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (19 backlog patches).

| `gap_kind` | Open | Route |
|------------|------|-------|
| `plan_debt` | 31 | `plan_verifier` + sim/security backlogs |
| `competitor_feature` | 30 | `gap_explorer` → numerics research goals |
| `missing_package` | 1 | `issue_planner` (`li-line-profiler`) |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — async swarm research lane per `docs/ecosystem/swarm-architecture.md`.

### Rows reconciled this pass

| Gap id | Action |
|--------|--------|
| `orch-r3-missing-package-sweep` | Confirm `gap-line-profiler-001` → `issue_planner`; close when package issue filed |
| `orch-r4-ui-ux-signals` | Handoff `ui_ux_quality` → `gui_ux_tester` |
| `gap-infra-verticals-toml-missing-benchmarks-main` | `gap_explorer` + `docs_maintainer` — land `verticals.toml` on benchmarks main |
| ph-db `wp-*` (9) | Route `database_platform` research goal — apply deferred |
| `studio-ux-16/17` | Defer until `STUDIO_UI_UX_PLAN_PATH` set |

---

## Briefing vs scorecard drift

| Source | Top agents |
|--------|------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

**Fix:** `benchmarks/scripts/enrich-briefing-scorecards.py` should union scorecard recommendations into `recommended_agents` and `heap_plan`.

---

## Handoffs (cite north_star_fit: ecosystem, ai)

| To agent | Reason |
|----------|--------|
| `gap_explorer` | 62 open gaps; `gap_pressure` score 60 |
| `plan_verifier` | 31 plan_debt; `plan_audit` preflight skipped |
| `ci_maintainer` | 27 repos missing CI on main |
| `security_auditor` | Top-25 CWE catalog gaps (19 missing) |
| `issue_planner` | MCP api-coverage tools + PyYAML image + `li-line-profiler` seed |
| `numerics_researcher` | Sim/security backlog patches need research follow-through |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781138502256.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-11-whitepaper-48602cda.md`
