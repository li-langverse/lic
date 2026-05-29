# Orchestrator note — orch-r4 stuck-run finalize

> 2026-05-29 · `swarm_observer` · gap_kind focus: cross-cutting execution reliability

## Context

Ecosystem grade **D** (66.3). `swarm_execution` dimension at 50 drives this meta-audit. Gap ingest/apply pipeline is healthy; execution telemetry and SDK finalization are not.

## Open gaps requiring orchestration (not product code)

| gap_id | kind | Action |
|--------|------|--------|
| `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` | plan_debt | Next orch todo: wire `gui_ux_tester` findings → `studio-ui-ux` plan + registry `ui_ux` rows |
| `gap-infra-verticals-toml-missing-benchmarks-main` | competitor_feature | Handoff `gap_explorer` — merge verticals.toml branch before ingest |
| `gap-benchmark-red-matmul-*`, `gap-benchmark-red-num-gmres-*` | competitor_feature | Active: `bench_improver` + `numerics_researcher` (PH-7e) |
| `gap-missing-std-std-summary`, `gap-missing-std-std-plot` | missing_package | Handoff `issue_planner` / `package_architect` — backlog patched |

## Registry apply status (2026-05-29T19:07Z)

- **Open:** 53
- **Patched this cycle:** 21 (sim backlogs, package backlog, vertical stubs)
- **Deferred:** 14 plan_debt (no runner backlog mapping)
- **Do not** install systemd plan loops for `sim` or `security-research` — use `research-goals.yaml` + control plane.

## Stopped runners → goal routing

| Runner | Pending todos | Suggested handoff |
|--------|---------------|-------------------|
| `compiler-studio` | wave-d GUI scaffold | `code_implementer` via research goal |
| `sim` | sim-p1-num-dot-axpy (patched) | `numerics_researcher` |
| `studio-ui-ux` | studio-ux wave2 | `studio_ui_ux_builder` (fix workflow_repo) |
| `sim-md-research` | md-r3-oracle-plan (patched) | `gap_explorer` research handoff |
| `sim-chem-research` | chem-r2/r3 (patched) | `gap_explorer` |
| `security-research` | sec-r1/r2/r3 | `security_auditor` + research goal |

## Control-plane fixes (li-cursor-agents PR)

1. Finalize stuck `running` SDK rows.
2. Refresh `control_plane_reports` each tick.
3. Enable observer retries for SDK premature errors.

## north_star_fit

Ecosystem orchestration · PH-7e numerics · proof-before-perf — no codegen shortcuts in this note.
