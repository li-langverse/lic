# Orchestrator note — performance gap orchestration (`e05514fc`)

**Date:** 2026-06-10  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Worker:** `e05514fc`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (67.3); `unattended_safe: false` |
| Gap prep | **Unblocked** — ingest + apply succeeded @ 03:54Z after env fallback fix + PyYAML |
| Open gaps | **62** (1 missing_package, 31 plan_debt, 30 competitor_feature) |
| Performance audit | **0 red** tier-1; **2 yellow**; **5 near-threshold** (~1.18–1.20× cpp) |
| Unattended? | **No** — missing CP state, zero run sampling, 6/9 runners stopped |

---

## Performance reconciliation (proof → easy → fast)

Pillar order enforced: no perf shortcuts before proof. Near-threshold benches are **eligible** for `bench_improver` only where PH-7e codegen paths are already proved.

| Bench id | Ratio vs cpp | Status | Route |
|----------|--------------|--------|-------|
| `num_opt_bfgs` | 1.1978 | near-threshold | `bench_improver` → `numerics_sota` |
| `num_integ_semi_implicit` | 1.19 | near-threshold | `bench_improver` |
| `num_integ_euler` | 1.1863 | near-threshold | `bench_improver` |
| `num_integ_rk4` | 1.1863 | near-threshold | `bench_improver` |
| `num_cg` | 1.1848 | near-threshold | `bench_improver` |
| `num_eig_symmetric` | yellow | `numerics_researcher` (PH-7e linalg) |
| `num_root_newton` | yellow | `numerics_researcher` |

**Stale registry rows:** `gap-benchmark-red-matmul-naive-tier1` and siblings remain `open` while `ecosystem-audit.benchmarks.red` is `[]`. Next ingest should auto-close when audit green persists.

**httpd perf plan debt:** `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` pending on `httpd` runner (exit 124 history). Route via `server_platform` research goal — not a new lic systemd loop.

---

## Gap orchestration actions

```bash
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py    # 92 registry rows; 62 open
python3 scripts/swarm-gap-apply-actions.py
# wrote benchmarks/data/latest/swarm-gap-actions.json
```

| `gap_kind` | Open | Patched this cycle | Handoff |
|------------|------|--------------------|---------|
| `missing_package` | 1 (`li-line-profiler`) | `pkg-line-profiler` pending | `issue_planner` |
| `plan_debt` | 31 | sim/security backlogs re-confirmed | `plan_verifier`, `implementation_gaps` |
| `competitor_feature` | 30 | vertical stubs → sim-md backlogs | `gap_explorer`, `bench_improver` |

**Skips:** 2 studio-ui patches — `/workspace/lic-studio-ui/.../2026-05-24-studio-ui-ux-plan-loop.md` not mounted.

---

## Control-plane fixes applied (orchestration only)

1. `swarm-gap-ingest.py` — `BENCHMARKS_COMPETITIVE` uses `os.environ.get()` fallback (no KeyError).
2. Worker image gap — `python3-yaml` installed via apt for this container; **bake into image** for unattended runs.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json` → `benchmarks`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/goal-directed-agents/snapshot.json`
- `/app/data/runs/swarm_observer-1781061516303.md`

---

## Handoffs (swarm goals — no new agent ids)

| Target | Work |
|--------|------|
| `bench_improver` | Near-threshold tier-1/2 numerics (5 rows) |
| `numerics_researcher` | Yellow eigen/Newton; PH-7e SIMD matmul debt |
| `gap_explorer` | Re-ingest after verticals.toml on main; close stale red rows |
| `issue_planner` | `li-line-profiler` package seed |
| `plan_verifier` | Master-plan partial phases (2e/2f/7d/7e/8p) |
| `pr_merger` | lip#52 (merge-approved) |
