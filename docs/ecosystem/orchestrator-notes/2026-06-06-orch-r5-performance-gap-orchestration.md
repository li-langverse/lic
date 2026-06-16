# Orchestrator note — `orch-r5-performance-gap-orchestration`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Supervisor dimension:** `performance`  
**Work item:** Reconcile perf-related swarm gaps; unblock gap ingest; route near-threshold + tier-1 registry rows

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (64.8); `unattended_safe: false` |
| Gap ingest | **Blocked** — `swarm-gap-ingest.py:229` SyntaxError |
| Perf near-threshold | 5 rows; lead **`simd_dot` 1.13×** cpp |
| Open perf gaps (registry) | 30 `competitor_feature` incl. 8 tier-1 red-class + HPC rows |
| Unattended? | **No** — ingest broken + 36 failing PRs + CP artifacts missing |

---

## Performance gap reconciliation

### Near-threshold (ecosystem audit 2026-06-05)

| Benchmark id | ratio_vs_cpp | Route |
|--------------|--------------|-------|
| `simd_dot` | 1.1279 | `sim-p1-num-dot-axpy` backlog → **`numerics_researcher`** / `md_sim_algorithms` |
| `md_init_fcc_mb` | 1.0199 | MD research backlog → **`numerics_researcher`** |
| `md_longrange_ewald` | 1.0139 | same |
| `md_integrator_verlet` | 1.0129 | same |
| `md_neighbor_cell_list` | 1.0121 | patched `sim-p1-md-neighbor-cell` |

### Tier-1 red-class (registry — competitor_feature)

Examples: `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1`, `gap-benchmark-red-num-opt-line-search-tier1`.

**Route:** **`bench_improver`** + **`autoresearch`** under PH-7e proof discipline — handoff cites PH-5b/7e on all PRs.

### HPC competitor rows

`gap-hpc-kokkos-execution-memory-spaces`, `gap-hpc-petsc-kokkos-implicit-pde`, `gap-hpc-fftw-roofline-catalog-row`, etc.

**Route:** research goals `scientific_distributed_computing`, `physics_sim` — no new systemd loops.

### Harness unblock

- **benchmarks#370** (li-parallel dual-mode) — CI failing; blocks Class A parallel evidence.
- Handoff: **`ci_maintainer`** → then **`bench_improver`**.

---

## Gap ingest failure (blocker)

```text
File "/workspace/lic/scripts/swarm-gap-ingest.py", line 229
  vert = Path(os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))/verticals.toml"
SyntaxError: unterminated string literal
```

**Required fix (human or lic PR):** close paren before `/verticals.toml"`:

```python
vert = Path(os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))) / "verticals.toml"
```

Until fixed, registry rows cannot auto-close on snapshot `completed_ids` updates.

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `ci_maintainer` | 3 repos missing CI; benchmarks metrics PRs CI red |
| `gap_explorer` | 64 open gaps; ingest blocked |
| `bench_improver` | Tier-1 red-class + near-threshold simd_dot |
| `numerics_researcher` | MD near-threshold cluster + sim backlog patches |
| `plan_verifier` | 31 plan_debt rows; PH-7e partial tracker |
| `issue_planner` | 3 missing_package backlog todos |

Research goal `swarm_coverage` remains on `swarm_observer` (cadence 6h) in `li-cursor-agents/config/research-goals.yaml`.

---

## Human-only

- Compiler / PH-7e codegen merges — provability gate required
- benchmarks#353–#373 metrics PR stack — human picks merge order vs #370
- httpd wrk soak (exit 124) — deadline tuning

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780730686219.md`
