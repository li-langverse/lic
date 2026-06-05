# Orchestrator note — `swarm_coverage@performance`

**Date:** 2026-06-05  
**Agent:** `swarm_observer` (worker `20ca95d4`)  
**Research goal:** `swarm_coverage`  
**north_star_fit:** ecosystem, ai — swarm gap orchestration with **performance** dimension focus (PH-5b, PH-7e; proof-before-perf)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (64.8); `unattended_safe: false` |
| Tier-1 benches | **0 red / 0 yellow**; 5 near-threshold greens (MD + `simd_dot`) |
| Gap pipeline | **Blocked** — PyYAML missing; ingest syntax bug fixed in working tree |
| Open gaps | 64 (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1 open) |
| Performance routing | Near-threshold MD + `simd_dot` → `numerics_researcher` / `bench_improver`; httpd wrk-soak → implement lane |

---

## Scripts executed

```bash
cd benchmarks && python3 scripts/ecosystem-quality-grade.py
# overall_score=64.8 grade=D unattended_safe=False

cd lic && python3 scripts/swarm-gap-ingest.py
# FAIL: PyYAML required (after syntax fix on line 229)

cd lic && python3 scripts/swarm-gap-apply-actions.py
# FAIL: PyYAML required
```

Prior successful apply artifact: `benchmarks/data/latest/swarm-gap-actions.json` @ 2026-05-31T01:45:58Z (23 backlog patches).

---

## Performance gap reconciliation

### Near-threshold (live audit)

Source: `benchmarks/data/latest/ecosystem-audit.json` @ 2026-06-05.

| Bench | Li/cpp | Registry / backlog link |
|-------|--------|-------------------------|
| `simd_dot` | 1.128× | `gap-competitor-pure-li-ph7e-catalog`; PH-7e partial in master plan |
| `md_neighbor_cell_list` | 1.012× | `gap-plan-pending-sim-sim-p1-md-neighbor-cell` → `sim-algorithm-backlog.md` (patched) |
| `md_integrator_verlet` | 1.013× | MD sim research backlog |
| `md_longrange_ewald` | 1.014× | MD sim research backlog |
| `md_init_fcc_mb` | 1.020× | MD sim research backlog |

### Stale tier-1 red rows (registry vs audit)

Registry still lists 8 `gap-benchmark-red-*` rows (e.g. `matmul_naive` 1.73×) but current `ecosystem-audit.json` reports **zero reds**. **Action:** enqueue `gap_explorer` to close/downgrade after ingest reruns; do not dispatch `bench_improver` on stale ratios.

### Plan_debt perf todos

| Todo | Runner | Handoff |
|------|--------|---------|
| `gap-phase2-perf-wrk-soak` | httpd | `code_implementer` (wrk soak gate) |
| `studio-ux-16-palette-search-latency` | studio-ui-ux | `gui_ux_tester` via `ui_ux_quality` goal |
| `sim-p1-num-dot-axpy` | sim | `numerics_researcher` — backlog patched |

---

## Swarm routing (no new systemd loops)

| Agent | Reason |
|-------|--------|
| `bench_improver` | `simd_dot` 1.128× — PH-7e lowering squeeze |
| `numerics_researcher` | MD near-threshold cluster + sim backlog todos |
| `gap_explorer` | Reconcile 8 stale red-gap rows; `verticals.toml` on benchmarks main |
| `ci_maintainer` | 33 failed PRs; unblock metrics refresh |
| `gui_ux_tester` | `studio-ux-16-palette-search-latency` |

---

## Control-plane fixes (this note)

1. **Merged fix:** `lic/scripts/swarm-gap-ingest.py` line 229 — `verticals.toml` Path fallback syntax.
2. **Runner deps:** add `PyYAML` to gap script preflight image.
3. **Scorecard:** fix `runs_dir` path for containerized `li-cursor-agents` mount.

---

## Evidence paths

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/ecosystem-audit.json`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `li-cursor-agents/data/runs/swarm_observer-1780631568441.md`
