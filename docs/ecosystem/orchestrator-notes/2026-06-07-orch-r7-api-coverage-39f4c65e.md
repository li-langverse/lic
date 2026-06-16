# Orchestrator note — orch-r7 api-coverage (worker 39f4c65e)

**Date:** 2026-06-07 · **Goal:** `swarm_coverage` · **Dimension:** `api-coverage`  
**Run:** `swarm_observer-1780809908983` · **north_star_fit:** ecosystem, ai

## Summary

Meta audit under the **api-coverage** lens: the swarm observer audit checklist depends on a chain of file/API surfaces (briefing JSON, gap registry YAML, gap apply actions, control-plane state, runs catalog). Three links in that chain are broken in the org-research worker container, blocking unattended gap orchestration.

## API surface audit

| Surface | Expected consumer | Status | Fix owner |
|---|---|---|---|
| `agent-briefing.json` | All agents | ✅ present | — |
| `ecosystem-quality-report.json` | `swarm_observer`, MCP | ✅ regenerated; needs `LI_CURSOR_AGENTS_ROOT=/app` | `benchmarks` scorecard script |
| `swarm-gap-registry/registry.yaml` | ingest, observer | ✅ present; parse blocked without PyYAML | worker image |
| `swarm-gap-actions.json` | observer, apply | ⚠️ stale (2026-05-31); apply cannot re-run | ingest + apply scripts |
| `data/control-plane/state.json` | observer retry budget | ❌ was ENOENT; bootstrapped | `li-cursor-agents` supervisor tick |
| `data/control-plane/latest-report.json` | observer health | ❌ was ENOENT; bootstrapped | same |
| `data/runs/*.json` | error sampling | ✅ 1 run at `/app/data/runs` | env default |
| MCP `get_briefing_snapshot` | research workers | ⚠️ fixture path drift reported in prior runs | `li-cursor-agents` MCP |
| `agent_deliverable_gate` | incomplete run scan | ❌ disabled | `LI_CURSOR_AGENTS_ENABLED=1` |

## Gap reconcile (blocked)

Ingest/apply did not run. Open gaps unchanged at **64** (31 plan_debt, 30 competitor_feature, 3 missing_package).

### Priority handoffs once unblocked

1. **`missing_package`:** `gap-line-profiler-001` → `issue_planner` (orch-r3)
2. **`plan_debt` sim:** `sim-p1-num-dot-axpy`, `sim-p1-md-neighbor-cell`, `sim-p2-qm-dft-scf` → sim-algorithm backlog patches
3. **`competitor_feature`:** `gap-infra-verticals-toml-missing-benchmarks-main` → `gap_explorer` + `docs_maintainer` (blocks vertical stub ingest)
4. **`ui_ux` (orch-r4):** studio-ui-ux todos `studio-ux-16/17` + benchmarks GPU picker #147 → `gui_ux_tester`

## Control-plane actions (no lic product code)

- Merge **one** lic PR fixing `swarm-gap-ingest.py:229` (dedupe lic#957–969 stack)
- Bake PyYAML in org-research worker; document in `deploy/org-worker-entrypoint.sh`
- Set `LI_CURSOR_AGENTS_ROOT=/app` in worker env defaults
- Add MCP read tools for gap registry + quality report (reduces manual path drift)

## Evidence

- Audit report: `/app/data/runs/swarm_observer-1780809908983.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Ingest failure: `/workspace/lic/scripts/swarm-gap-ingest.py:229`
