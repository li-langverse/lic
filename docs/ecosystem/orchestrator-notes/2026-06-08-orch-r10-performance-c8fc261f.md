# Orchestrator note — `orch-r10-performance` (worker `c8fc261f`)

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Work item:** Reconcile perf-related gap rows; unblock ingest; route PH-7e yellow + httpd wrk soak

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **C** (74.1); `unattended_safe: false` |
| Gap pipeline | **Blocked** — PyYAML missing; ingest syntax **fixed locally** (line 229) |
| Perf signal | 0 red tier-1; **2 yellow**; **5 near-threshold** (~1.18–1.20× cpp) |
| httpd perf debt | `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` pending in snapshot |
| sim perf debt | `sim-p1-num-dot-axpy`, `sim-p1-md-neighbor-cell`, `sim-p2-qm-dft-scf` open in registry |
| Unattended? | **No** — ingest/apply + CI preflight must green first |

---

## Programmatic prep status

```bash
python3 lic/scripts/swarm-gap-ingest.py
# BEFORE: SyntaxError line 229
# AFTER fix: PyYAML required (pip install pyyaml) — still blocked in worker image

python3 lic/scripts/swarm-gap-apply-actions.py
# PyYAML required — not executed live
```

Last successful apply artifact: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` @ 2026-05-31T01:45:58Z (64 open gaps).

---

## Performance gap taxonomy (this pass)

| gap_kind | perf-relevant open rows | Primary discoverer | Swarm route |
|----------|-------------------------|-------------------|-------------|
| `competitor_feature` | `gap-benchmark-red-matmul-naive-tier1`, `num_gmres`, integrator reds | `gap_explorer` | `bench_improver`, `numerics_researcher` |
| `plan_debt` | httpd wrk soak, sim dot/axpy, PH-7e/8p master-plan partials | `plan_verifier` | implement goals + `issue_planner` |
| `ui_ux` | `studio-ux-16-palette-search-latency` | `gui_ux_tester` | `ui_ux_quality` goal |
| `missing_package` | `gap-line-profiler-001` | `gap_explorer` | `issue_planner` → package backlog |

**Pillar order respected:** PH-7e SIMD lowering remains proof-gated; no unproved perf shortcuts.

---

## Backlog patches (from last apply — stale)

Performance-relevant patches already recorded in `swarm-gap-actions.json`:

- `sim-p1-num-dot-axpy` → `sim-algorithm-backlog.md`
- `sim-p2-qm-dft-scf` → `sim-algorithm-backlog.md`
- `md-r3-oracle-plan` → `sim-md-research-backlog.md`
- `chem-r2-dft-scf-gap` → `sim-chem-research-backlog.md`

Re-run apply after PyYAML + ingest merge to refresh timestamps.

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `bench_improver` | Yellow/near-threshold numerics; tier-1 red competitor_feature rows |
| `numerics_researcher` | PH-7e master-plan partial + md/chem sim perf backlogs |
| `gap_explorer` | 64 open registry rows; verticals.toml ingest blocked |
| `ci_maintainer` | 12 repos missing CI; preflight 403 |
| `pr_merger` | lip#52 gate-ready |

Research goal `swarm_coverage` cadence 6h in `li-cursor-agents/config/research-goals.yaml` — handoff_to: `gap_explorer`, `plan_verifier`, `issue_planner`.

---

## Control-plane fixes (file paths)

1. `lic/scripts/swarm-gap-ingest.py:229` — Path fallback (fixed; needs PR merge)
2. `li-cursor-agents/deploy/org-worker-entrypoint.sh` — install PyYAML
3. `benchmarks/scripts/ecosystem-quality-grade.py` — default `LI_CURSOR_AGENTS_ROOT=/app`
4. `li-cursor-agents/src/control-plane/runtime.ts` — persist observer state each tick

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/app/data/runs/swarm_observer-1780879148917.md`
- `/workspace/lic/docs/research/swarm_coverage/performance/2026-06-08-whitepaper-c8fc261f.md`
