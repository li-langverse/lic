# Orchestrator note — swarm_coverage @ performance

**Date:** 2026-06-04  
**Run:** `swarm_observer-1780578997929` · **Worker:** `792ea6a5`  
**Goal:** `swarm_coverage` (research lane, not lic systemd plan loop)

## Summary

Performance-oriented gap reconcile after control-plane meta audit. Ecosystem grade **D (64.8)**; **62 open** swarm-gap registry rows. Live benchmark audit shows **no tier-1 red rows** but **140+ unknown** catalog entries — registry still carries stale `gap-benchmark-red-*` competitor_feature rows until catalog honesty PRs land.

## Actions

1. Regenerated `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`.
2. Fixed `lic/scripts/swarm-gap-ingest.py`:
   - `BENCHMARKS_COMPETITIVE` uses `os.environ.get(..., LANGVERSE/benchmarks/workloads/competitive)` (no KeyError).
3. Ran `swarm-gap-ingest.py` → registry **92** total gaps; **62 open**.
4. Ran `swarm-gap-apply-actions.py` → patched sim/security/md backlogs; deferred ph-db + master-plan plan_debt; skipped studio-ui (missing `lic-studio-ui` mount).

## Performance handoffs (existing agents only)

| Gap id (sample) | Handoff |
|-----------------|---------|
| `gap-benchmark-red-matmul-naive-tier1` | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-gmres-tier1` | `numerics_researcher` |
| `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` | httpd plan todo / `code_implementer` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | `plan_verifier`, `issue_planner` |
| `gap-hpc-kokkos-execution-memory-spaces` | `numerics_researcher`, `issue_planner` |

## Blockers

- Benchmarks PR CI (#329–#339) blocks merging refreshed metrics.
- Control-plane disk cache empty on org-research Job — observer auto-retry not observable.
- Do **not** add systemd plan loops; use `li-cursor-agents` research/implement goals.

## Evidence

- Report: `/app/data/runs/swarm_observer-1780578997929.md`
- Apply log: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
