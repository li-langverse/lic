# Orchestrator note — `swarm_coverage@api-coverage`

**Date:** 2026-06-04  
**Agent:** `swarm_observer` (worker `05d0493b`)  
**Research goal:** `swarm_coverage` — north_star_fit: ecosystem, ai  
**Dimension:** `api-coverage`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.3); `unattended_safe: false` |
| Gap pipeline | Ingest syntax fixed; apply OK after `python3-yaml`; open gaps **62** |
| Control-plane APIs | MCP Postgres down; disk `latest-report.json` / `state.json` absent |
| `orch-r3` / `orch-r4` | r3 backlog sweep done (note 2026-05-31); r4 UX signals → `gui_ux_tester` / `ui_ux_quality` |
| Unattended? | **No** — preflight/GitHub limits, CI-failing PR wave, heap ignores security P0 |

---

## API-coverage audit (orchestration surface)

| Surface | Status | Evidence |
|---------|--------|----------|
| `li-control-plane-db` MCP (`query_control_plane_db`) | **Unavailable** | `ECONNREFUSED 127.0.0.1:54322` |
| `li-ecosystem-context` MCP (`get_briefing_snapshot`) | **OK** | Returns `recommended_agents`, `generated_at` |
| Disk CP cache (`data/control-plane/latest-report.json`) | **Missing** | Observer cannot persist heal state |
| `swarm-gap-ingest.py` | **Fixed L229** | Was `SyntaxError`; fallback path for `verticals.toml` |
| `swarm-gap-apply-actions.py` | **OK** (needs PyYAML) | Wrote `benchmarks/data/latest/swarm-gap-actions.json` |
| Org-research persist (`agent_runs` upsert) | **Intermittent** | Historical `undefined`; recent dims `finished` |
| Briefing preflight APIs | **Partial** | `org_ci_audit` 403 rate limit; `org_agent_kit_audit` missing `roadmap/agent-kit` |

**Recommendation:** bake `python3-yaml`, set `LIC_ROOT` + `BENCHMARKS_COMPETITIVE` in org-research Job; restore Supabase or write CP disk cache each supervisor tick.

---

## Open gap reconciliation (this pass)

| `gap_kind` | Open | Action |
|------------|------|--------|
| `missing_package` | 1 | `gap-line-profiler-001` → `issue_planner` / `ecosystem-package-backlog.md` |
| `plan_debt` | 31 | Runner backlogs patched; ph-db + master-plan rows deferred |
| `competitor_feature` | 30 | Route `numerics_researcher`, `bench_improver`, `gap_explorer` |

**orch-r4-ui-ux-signals:** link `studio-ux-16` / `studio-ux-17` to `ui_ux_quality` goal; handoff `gui_ux_tester` (no new registry ids).

Handoffs cite north_star_fit: ecosystem, ai — proof-before-perf on numerics gaps (PH-5b, PH-7e).

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/app/data/runs/swarm_observer-1780549649012.md`
