# Orchestrator note — `swarm_coverage` @ `api-coverage`

**Date:** 2026-06-04  
**Run:** `swarm_observer-1780545214532`  
**Worker:** `031a1541`  
**north_star_fit:** ecosystem, ai — gap registry → backlog → handoff APIs must be callable without shell

## Context

Org-research dimension **api-coverage** audits whether meta-agents can read/write orchestration surfaces (MCP control plane, gap registry, scorecard, briefing) without human intervention. Ecosystem grade **D (67.8)**; `unattended_safe: false`.

## Gap pipeline

| Step | Status | Evidence |
|------|--------|----------|
| Read `registry.yaml` | OK | 62 `status: open` |
| Read `swarm-gap-actions.json` | OK (stale 2026-05-31) | 64 open, 23 patches |
| `swarm-gap-ingest.py` | **Blocked** → syntax fixed locally | L229 Path fallback |
| `swarm-gap-apply-actions.py` | **Blocked** | PyYAML missing in Job image |

## Reconcile actions (no product code)

### `missing_package` (1 open: `gap-line-profiler-001`)

- **Backlog:** `docs/ecosystem/ecosystem-package-backlog.md` → `pkg-line-profiler`
- **Handoff:** `issue_planner` (research seed, not implementation in lic)

### `plan_debt` — swarm-observer todos

| Todo | Action |
|------|--------|
| `orch-r3-missing-package-sweep` | Close after `issue_planner` picks up line-profiler + std gaps |
| `orch-r4-ui-ux-signals` | Handoff `gui_ux_tester` + `ui_ux_quality` goal; link lic#575 studio-ux-16/17 |

### `plan_debt` — sim / security (patch when apply runs)

- `sim-p1-num-dot-axpy` → `numerics_researcher` via `md_sim_algorithms` / PH-7e
- `sec-r1-httpd-fuzz-smoke`, `sec-r2-tier5-gap-exploit`, `sec-r3-runtime-surface` → `offensive_security` goal / `security_auditor`

### `competitor_feature` (30 open)

- Do **not** spawn new lic systemd loops — route via swarm goals (`numerics_sota`, `physics_sim`, `gap_explorer` cadence)
- Tier-1 red rows (`matmul_naive`, `num_gmres`, …) → `bench_improver` + `numerics_researcher` after proof gates

## Control-plane API gaps (api-coverage)

1. MCP Postgres down — add PostgREST fallback
2. Missing disk mirrors — persist `latest-report.json` + `state.json`
3. Grader `runs_dir` wrong — point to `/app/data/runs`
4. Bake `python3-yaml` in org-research image

## Handoffs

| Agent | Reason |
|-------|--------|
| `gap_explorer` | Refresh competitor_feature + verticals ingest after ingest fix merges |
| `plan_verifier` | Unblock `plan_audit` preflight; refresh goal-directed snapshot |
| `ci_maintainer` | `li-sec-agent` missing CI |
| `security_auditor` | 19 Top25 CWE catalog gaps |
| `issue_planner` | `pkg-line-profiler-001` |
| `gui_ux_tester` | studio-ux-16/17 (orch-r4) |

## Evidence

- Report: `/app/data/runs/swarm_observer-1780545214532.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- Actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
