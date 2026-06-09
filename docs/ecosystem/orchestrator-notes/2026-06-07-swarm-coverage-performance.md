# Orchestrator note — `swarm_coverage` @ performance

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance` (worker `eb79bd7e`)  
**Work item:** Reconcile open performance-related gap rows; route handoffs via async swarm goals (no new systemd loops)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (62.9)**; `unattended_safe: false` |
| Gap registry | **64 open** — apply artifact stale since 2026-05-31 |
| Ingest/apply | **Blocked** — `swarm-gap-ingest.py:229` SyntaxError; PyYAML missing for apply |
| Control plane | **No disk state** — observer auto-heal inactive |
| Performance bench | 2 yellow, 5 near-threshold numerics vs cpp |
| Unattended? | **No** — fix ingest syntax + hydrate control-plane before routine gap orchestration |

---

## Performance gap reconcile

### `competitor_feature` → research lane

| Registry id | PH | Handoff | Goal id |
|-------------|-----|---------|---------|
| `gap-benchmark-red-matmul-naive-tier1` | PH-7e | `bench_improver`, `numerics_researcher` | `numerics_sota` |
| `gap-benchmark-red-num-gmres-tier1` | PH-5b | `numerics_researcher` | `numerics_sota` |
| `gap-benchmark-red-num-integ-euler-tier1` | PH-5b | `numerics_researcher`, `bench_improver` | `physics_sim` |
| `gap-benchmark-red-num-opt-line-search-tier1` | PH-5b | `numerics_researcher` | `numerics_sota` |
| `gap-hpc-kokkos-execution-memory-spaces` | PH-7e | `numerics_researcher`, `issue_planner` | `scientific_distributed_computing` |
| `gap-competitor-pure-li-ph7e-catalog` | PH-7e | `bench_improver` | `numerics_sota` |

Briefing yellow rows (`num_eig_symmetric`, `num_root_newton`) align with PH-7e; near-threshold integrators (`num_opt_bfgs`, `num_integ_*`, `num_cg`) are watch-list for `autoresearch` after proof gates.

### `plan_debt` → backlog already patched (stale apply)

| Todo id | Backlog | Swarm route |
|---------|---------|-------------|
| `sim-p1-num-dot-axpy` | `sim-algorithm-backlog.md` | `numerics_researcher` / `md_sim_algorithms` |
| `sim-p1-md-neighbor-cell` | `sim-algorithm-backlog.md` | Active PRs lic#977/#980 — human dedupe |
| `sim-p2-qm-dft-scf` | `sim-algorithm-backlog.md` | lic#1005 |
| `gap-phase2-perf-wrk-soak` | httpd runner snapshot | `goal_researcher` via `server_platform` research — **not** new httpd systemd loop |
| `studio-ux-21-wgpu-swapchain-gpu-runner` | studio-ui-ux plan | `gui_ux_tester` / `ui_ux_quality` |

### `missing_package`

| Registry id | Todo | Handoff |
|-------------|------|---------|
| `gap-line-profiler-001` | `pkg-line-profiler` | `issue_planner` (HPC profiling seed) |

---

## Scripts status (this run)

```bash
# FAILED — syntax error
LIC_ROOT=/workspace/lic python3 scripts/swarm-gap-ingest.py
# SyntaxError: unterminated string literal at line 229

# FAILED — missing dependency
LIC_ROOT=/workspace/lic python3 scripts/swarm-gap-apply-actions.py
# swarm-gap-apply-actions: PyYAML required
```

**Action:** Fix ingest script on `lic` main, install PyYAML in gap-apply environment, re-run ingest → apply → refresh `benchmarks/data/latest/swarm-gap-actions.json`.

---

## Swarm routing (no new registry ids / no systemd loops)

| Agent | Reason |
|-------|--------|
| `numerics_researcher` | Yellow + near-threshold numerics; competitor_feature PH-5b/7e gaps |
| `bench_improver` | Tier-1 red catalog + matmul/integrator microbenches |
| `plan_verifier` | Refresh goal-directed snapshot; close orch-r3/r4 after ingest fix |
| `gap_explorer` | `gap-infra-verticals-toml-missing-benchmarks-main` |
| `ci_maintainer` | 14 repos missing CI — merge throughput |
| `pr_merger` | lip#52 gate-ready |
| `swarm_observer` | Meta audit until control-plane state hydrated |

Research goal row unchanged: `li-cursor-agents/config/research-goals.yaml` → `swarm_coverage`, agent `swarm_observer`, cadence 6h.

---

## Registry plan-debt rows (swarm-observer runner)

| Todo | Status | Next step |
|------|--------|-----------|
| `orch-r3-missing-package-sweep` | open | Close after ingest + `pkg-line-profiler` handoff confirmed |
| `orch-r4-ui-ux-signals` | open | Link studio-ux-16/17 to `ui_ux_quality` goal |

---

## Human-only

- Fix `swarm-gap-ingest.py` syntax — lic PR required
- lic#436 registry merge conflict (if still open)
- Duplicate sim PRs lic#977 vs lic#980
- Governance draft lic#992

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780830215556.md`
- `/app/data/goal-directed-sprints/org-swarm-stability-audit.jsonl`
