# Swarm coverage — org-packages audit

**Goal id:** `swarm_coverage`  
**Dimension:** `org-packages`  
**Worker:** `5661feaf`  
**Date:** 2026-06-08  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/org-packages/`

---

## Abstract

This pass audits the li-langverse **org package surface** through the swarm gap orchestration lens: registry rows, package backlog todos, and cross-repo CI posture. One durable `missing_package` gap remains (`li-line-profiler` seed). Four std-module gaps are closed in both registry and backlog. Twelve org repositories lack CI on `main`, blocking unattended package hygiene. The gap ingest/apply pipeline is blocked by missing PyYAML in the worker runtime and a syntax defect in `swarm-gap-ingest.py` (remediated locally).

---

## Method

1. Refreshed `ecosystem-quality-report.json` via `benchmarks/scripts/ecosystem-quality-grade.py`.
2. Read `lic/data/swarm-gap-registry/registry.yaml` and `benchmarks/data/latest/swarm-gap-actions.json`.
3. Cross-checked `lic/docs/ecosystem/ecosystem-package-backlog.md`.
4. Audited `benchmarks/data/latest/ecosystem-audit.json` → `missing_ci_on_main`.
5. Attempted `lic/scripts/swarm-gap-ingest.py` + `swarm-gap-apply-actions.py`.

---

## Findings

### 1. Package module gaps (registry)

| Status | Count | Notes |
|--------|-------|-------|
| Open `missing_package` | 1 | `gap-line-profiler-001` only |
| Closed std modules | 4 | io, csv, summary, plot — backlog **completed** |

The explorer/backlog drift from May 2026 is resolved for std modules; orchestrator should auto-close any stale open rows on next successful ingest.

### 2. Org package CI posture

**12 repositories** lack a CI workflow on `main` (2026-06-08 ecosystem audit). These span gateway, auth, blob, books, research MCP, and telemetry packages — all structural prerequisites for proof-before-perf package delivery.

Briefing routes this to **`ci_maintainer`** (priority 50). This is an org-packages finding outside the gap registry taxonomy.

### 3. Plan debt — chemistry package placement

Open registry row `gap-plan-pending-sim-chem-research-chem-r3-package-placement` tracks QM simulation package placement. Handoff chain: **`numerics_researcher`** (`chem_sim_algorithms` goal) → **`package_architect`** → **`issue_planner`**.

### 4. Gap pipeline health

| Blocker | Impact |
|---------|--------|
| PyYAML missing in container | ingest + apply cannot run |
| `swarm-gap-ingest.py:229` SyntaxError | vertical stub ingest broken (fixed locally) |
| Stale `swarm-gap-actions.json` (2026-05-31) | 64 open rows may not reflect backlog completions |

---

## Recommendations

1. **`issue_planner`:** file seed issue for `li-line-profiler` (`pkg-line-profiler`, PH-7e profiling hooks).
2. **`ci_maintainer`:** scaffold CI for the 12 `missing_ci_on_main` repos (batch PRs, human review).
3. **`package_architect`:** placement doc for chem QM packages (`chem-r3-package-placement`).
4. **Infra:** bake `python3-yaml` into org-research worker image; merge ingest syntax fix to `lic` main.
5. **`gap_explorer`:** re-run after PyYAML to reconcile 64 open rows vs completed backlog todos.

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (65.8, grade D)
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/ecosystem-package-backlog.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-org-packages-5661feaf.md`
- `/app/data/runs/swarm_observer-1780951393789.md`

---

## Pillar alignment

| Pillar | Link |
|--------|------|
| Provable | Package CI gates proof certificates before release |
| Easy | std modules (plot, summary) reduce agent dependency on Node/Python |
| Fast | `li-line-profiler` seed supports HPC agent loop tuning (post-proof) |
