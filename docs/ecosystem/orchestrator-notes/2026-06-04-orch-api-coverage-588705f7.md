# Orchestrator note — api-coverage (`orch-api-coverage-588705f7`)

**Date:** 2026-06-04T12:28Z  
**Run:** `swarm_observer-1780575397584`  
**Worker:** `588705f7`  
**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**north_star_fit:** ecosystem, ai — proof-before-perf on cataloged APIs

## Summary

API-coverage audit for swarm gap orchestration: competitive vertical `kernel_or_api` registry, benchmark workload API matrix, and agent-facing CLI JSON surfaces. Ingest/apply pipeline was blocked by `swarm-gap-ingest.py` L229 syntax and missing PyYAML; both remediated on this host. **62 open gaps** remain after apply.

## Evidence paths

| Artifact | Path |
|----------|------|
| Vertical registry | `benchmarks/benchmarks/workloads/competitive/verticals.toml` (15 rows) |
| Gap registry | `lic/data/swarm-gap-registry/registry.yaml` |
| Gap actions | `benchmarks/data/latest/swarm-gap-actions.json` @ 2026-06-04T12:28:45Z |
| Scorecard | `benchmarks/data/latest/ecosystem-quality-report.json` (64.8, D) |
| Observer digest | `li-cursor-agents/data/runs/swarm_observer-1780575397584.md` |

## API-coverage findings

1. **Vertical `kernel_or_api`:** 12/15 rows `workload_class=stub` or `partial` — incumbent APIs (LAMMPS, OpenFOAM, Gaussian, ParaView, etc.) not at Li parity; rows already patched to `sim-md-research-backlog.md` via apply.
2. **Benchmark workload APIs:** 140+ catalog entries `unknown` in live briefing — no tier-1 coverage signal for httpd (`https_static`, `lb_*`), numerics, MD, QM, viz pipelines.
3. **Vision-LLM agent API:** master-plan gap for full `lic check --format=json` + `lic diagnose` — route `plan_verifier` / `issue_planner` (proof gates first).
4. **Ingest path:** `BENCHMARKS_COMPETITIVE` must default to mounted benchmarks competitive dir; L229 bug prevented fallback when env unset.

## Reconcile actions (no product code)

| Gap id / area | Action | Handoff |
|---------------|--------|---------|
| `gap-line-profiler-001` | Backlog pending | `issue_planner` |
| `gap-infra-verticals-toml-missing-benchmarks-main` | Unblock via benchmarks catalog PRs #324–#337 | `gap_explorer`, human merge |
| Tier-1 `competitor_feature` reds | Registry open | `bench_improver`, `numerics_researcher` |
| `orch-r3-missing-package-sweep` | std.summary/plot closed in registry; profiler open | close todo after profiler issue |
| studio-ux-21/24 | apply skipped (plan mount) | `gui_ux_tester` / `ui_ux_quality` goal |

## Control-plane fixes (sibling repos)

- `li-cursor-agents`: bake `python3-yaml`, persist CP disk cache, enqueue `gap_explorer` + `security_auditor` on briefing P0.
- `benchmarks`: fix grader `runs_dir` for `/app`; refresh metrics after catalog CI green.

## Do not

- Add new lic systemd plan loops (`install-goal-plan-loop-systemd.sh` retired).
- Invent new agent registry ids.
- Auto-merge governance or catalog-honesty PRs.
