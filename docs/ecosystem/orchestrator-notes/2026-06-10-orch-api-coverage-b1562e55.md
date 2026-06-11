# Orchestrator note — API-coverage gap orchestration (`b1562e55`)

**Date:** 2026-06-10  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `b1562e55`  
**Run:** `1781126805691`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (75.6), `unattended_safe: true` conditional |
| Gap prep | **Ingest blocked** (PyYAML); apply artifact **stale @ 14:45Z** |
| Open gaps | **62** (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1) |
| API coverage | REST endpoints present in ops-server; MCP scorecard/registry reads **missing**; CP disk mirrors **absent** |
| Observer self-heal | **None observable** — no persisted interventions in this pod |

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
| `read_swarm_gap_actions` | **missing** |
| `get_briefing_snapshot` | partial — no quality report, gap actions, `ecosystem_explorer: null` |

### Infra API dependency

`swarm-gap-ingest.py` requires PyYAML — blocked in this pod (`ModuleNotFoundError: yaml` / CLI message). Treat as deploy API contract: bake `python3-yaml` in org-research worker image.

### Control-plane persistence gap

`/app/data/control-plane/state.json` and `latest-report.json` absent. Auditor cannot verify `observer.retry_counts` or `stopped_agents` — self-heal audit incomplete despite `swarm_execution` score 100.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (ingest blocked this run):
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py   # OK 22:15Z
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py                  # FAIL PyYAML
python3 scripts/swarm-gap-apply-actions.py                                # FAIL PyYAML
```

Last successful apply artifact: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (19 backlog patches @ 14:45Z).

| `gap_kind` | Open | Route |
|------------|------|-------|
| `plan_debt` | 31 | 9 patched; 20 master-plan deferred → `plan_verifier` + `issue_planner` |
| `competitor_feature` | 30 | 9 patched; 21 handoff-only → `gap_explorer` / numerics goals |
| `missing_package` | 1 | `issue_planner` (`li-line-profiler`) |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — async swarm research lane per `docs/ecosystem/swarm-architecture.md`.

### Rows needing handoff (no backlog mapping)

- Master-plan partial phases (Doc-c, 2e–2f, 2i, 7d, 7e, Phase H, Vision-LLM) → `issue_planner` with lic master-plan anchors
- ph-db wp-* (9) → `database_platform` research goal
- studio-ux-16/17 → mount `lic-studio-ui` or route via `ui_ux_quality` goal

---

## Briefing vs scorecard drift

| Source | Recommended agents |
|--------|-------------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

Fix: extend briefing heap builder when `gap_pressure` < 80 or preflight plan_audit skipped.

---

## Handoffs (cite north_star_fit: ecosystem, ai)

| To agent | Reason |
|----------|--------|
| `gap_explorer` | 62 open gaps; scorecard `gap_pressure` 60 |
| `plan_verifier` | 31 plan_debt; plan_audit preflight skipped |
| `ci_maintainer` | 28 repos missing CI on main |
| `security_auditor` | Top-25 CWE catalog gaps (19) |
| `issue_planner` | MCP api-coverage tools + PyYAML image + line-profiler package |
| `gui_ux_tester` | studio-ux backlog when worktree mounted |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (refreshed 22:15Z)
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781126805691.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-10-whitepaper-b1562e55.md`
