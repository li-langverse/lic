# Orchestrator note — swarm_coverage @ api-coverage (2026-06-04)

**Worker:** `fa3519e7`  
**Run:** `swarm_observer-1780606004228`  
**north_star_fit:** ecosystem + ai — gap registry / backlog apply / handoffs (proof-before-perf)

## Summary

api-coverage audit of swarm gap orchestration: control-plane **JSON/YAML contracts** are defined, but **CLI ingest/apply** cannot run in the current agent container (`PyYAML` missing; ingest L229 syntax error on `main`). Scorecard **D (64.8)**, `unattended_safe: false`.

## Evidence

| Artifact | Path |
|----------|------|
| Scorecard | `benchmarks/data/latest/ecosystem-quality-report.json` |
| Briefing | `benchmarks/data/latest/agent-briefing.json` |
| Gap registry | `lic/data/swarm-gap-registry/registry.yaml` (62 open) |
| Gap actions | `benchmarks/data/latest/swarm-gap-actions.json` (stale 2026-05-31) |
| Observer digest | `li-cursor-agents/data/runs/swarm_observer-1780606004228.md` |
| Whitepaper | `lic/docs/research/swarm_coverage/api-coverage/2026-06-04-whitepaper.md` |

## Reconcile (open → action)

| Gap / todo | Action |
|------------|--------|
| `gap-infra-verticals-toml-missing-benchmarks-main` | Handoff `gap_explorer` after benchmarks catalog PR lands |
| `gap-line-profiler-001` | `issue_planner` — `ecosystem-package-backlog.md` `pkg-line-profiler` |
| `gap-plan-debt-lic-master-plan-vision-llm-*` | `issue_planner` — agent JSON API (`lic check --format=json`, diagnose) |
| `orch-r3-missing-package-sweep` | This observer pass; close when 3 `missing_package` rows triaged |
| `orch-r4-ui-ux-signals` | Handoff `gui_ux_tester` / goal `ui_ux_quality` (not systemd studio loop) |
| sim `sim-p1-*`, chem `chem-r2-*` | Already patched in `swarm-gap-actions.json`; implement via `numerics_researcher` goals |

## Control-plane (no lic product code)

1. Merge **lic#837** (ingest Path fallback) — dedupe with #828–#845 stack.
2. Bake **python3-yaml** in `li-cursor-agents` runtime.
3. Do **not** add `install-goal-plan-loop-systemd.sh` for gap rows — use async swarm + `research-goals.yaml`.

## Human-only

- benchmarks metrics PR wave CI
- CWE Top25 catalog edits
- GitHub API rate limit cooldown
