# Swarm coverage — performance dimension (2026-06-05)

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `20ca95d4`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance.md`  
**north_star_fit:** ecosystem, ai — orchestrate perf gaps without bypassing proof (PH-5b, PH-7e)

---

## Abstract

This pass audits swarm health through a **performance lens**: benchmark posture, gap-registry perf rows, and plan-debt perf todos. Tier-1 execution is **healthy** (39 greens, 0 reds) but **five near-threshold** workloads and **64 open swarm gaps** keep perf pressure on the orchestration lane. Gap ingest/apply failed in the runner image (PyYAML + ingest syntax), so registry rows lag the live audit.

---

## Tier-1 benchmark posture

| Metric | Value | Source |
|--------|-------|--------|
| Green | 39 | `ecosystem-audit.json` |
| Red | 0 | same |
| Yellow | 0 | same |
| Near-threshold (≥1.01× cpp) | 5 | same |

### Near-threshold watchlist

1. **`simd_dot`** — 1.128× cpp. Dominant PH-7e vectorized-reduction gap; route `bench_improver` before `autoresearch`.
2. **`md_neighbor_cell_list`** — 1.012×. Linked to `sim-p1-md-neighbor-cell` plan todo (backlog patched 2026-05-31).
3. **`md_integrator_verlet`** — 1.013×. Symplectic integrator class; `numerics_researcher` / `md_sim_algorithms` goal.
4. **`md_longrange_ewald`** — 1.014×. Long-range MD; same vertical.
5. **`md_init_fcc_mb`** — 1.020×. Initialization path; same vertical.

**Pillar order:** All routes assume `lic build` proof gates remain green; no `unsafe` perf shortcuts.

---

## Gap registry — performance taxonomy

| `gap_kind` | Open | Perf-relevant examples |
|------------|------|------------------------|
| `competitor_feature` | 30 | 8 `gap-benchmark-red-*` (stale vs audit), Kokkos/PETSc/HPC library rows |
| `plan_debt` | 31 | PH-7e SIMD partial, 8p CI throughput, httpd wrk-soak, studio palette latency |
| `missing_package` | 1 | `li-line-profiler` (HPC agent loop profiling) |

### Registry vs audit drift

Eight `gap-benchmark-red-*` entries cite tier-1 ratios (e.g. `matmul_naive` 1.73×) that **no longer appear** in `ecosystem-audit.json` reds. Closing these via `gap_explorer` ingest prevents false `bench_improver` dispatch.

---

## Orchestration health (performance impact)

| Signal | Impact on perf lane |
|--------|---------------------|
| 33 failed benchmarks PRs | Metrics/catalog refresh blocked — obscures perf trends |
| PyYAML missing on gap runners | Backlog apply stalled — sim/httpd perf todos not re-patched |
| 6 stopped goal-directed runners | httpd wrk-soak + sim MD todos idle |
| `runs_sampled: 0` in scorecard | Observer cannot auto-retry perf agents |

---

## Recommended handoffs

| Priority | Agent | Work |
|----------|-------|------|
| P0 | `ci_maintainer` | Unblock benchmarks metrics PR CI |
| P1 | `bench_improver` | `simd_dot` PH-7e squeeze |
| P1 | `numerics_researcher` | MD near-threshold cluster |
| P1 | `gap_explorer` | Close stale red-gap rows; land `verticals.toml` on benchmarks main |
| P2 | `code_implementer` | httpd `gap-phase2-perf-wrk-soak` |
| P2 | `gui_ux_tester` | `studio-ux-16-palette-search-latency` |

---

## Evidence index

- `benchmarks/data/latest/ecosystem-quality-report.json` (grade D, 64.8)
- `benchmarks/data/latest/ecosystem-audit.json` (benchmarks block)
- `benchmarks/data/latest/benchmark-matrix.md`
- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-05-orch-swarm-coverage-performance-20ca95d4.md`
- `li-cursor-agents/data/runs/swarm_observer-1780631568441.md`
