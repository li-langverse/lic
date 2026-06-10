# Orchestrator note — performance gap orchestration (`ac701e52`)

**Date:** 2026-06-10  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Worker:** `ac701e52`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (conditional)** — grade **C** (75.6); `unattended_safe: true` |
| Gap prep | **Unblocked** — ingest + apply succeeded @ 14:45Z after `python3-yaml` apt install |
| Open gaps | **62** (1 missing_package, 31 plan_debt, 30 competitor_feature) |
| Performance audit | **0 red** tier-1; **2 yellow**; **5 near-threshold** (~1.18–1.20× cpp) |
| Control plane | **Missing** `state.json` / `latest-report.json` — observer blind |
| Unattended? | **Conditional** — SDK auth OK; gap closure + CI dispatch need supervisor fixes |

---

## Performance reconciliation (proof → easy → fast)

Pillar order enforced: no perf shortcuts before proof. Near-threshold benches are eligible for `bench_improver` only where PH-7e codegen paths are already proved.

| Bench id | Ratio vs cpp | Status | Route |
|----------|--------------|--------|-------|
| `num_opt_bfgs` | 1.1978 | near-threshold | `bench_improver` → `numerics_sota` |
| `num_integ_semi_implicit` | 1.19 | near-threshold | `bench_improver` |
| `num_integ_euler` | 1.1863 | near-threshold | `bench_improver` |
| `num_integ_rk4` | 1.1863 | near-threshold | `bench_improver` |
| `num_cg` | 1.1848 | near-threshold | `bench_improver` |
| `num_eig_symmetric` | yellow | `numerics_researcher` (PH-7e linalg) |
| `num_root_newton` | yellow | `numerics_researcher` |

**Stale registry rows:** `gap-benchmark-red-matmul-naive-tier1` and 8 sibling tier-1 red rows remain `open` while `ecosystem-audit.benchmarks.red` is `[]`. Next ingest should auto-close when audit green persists.

**httpd perf plan debt:** `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` pending on `httpd` runner (exit 124 history). Route via `server_platform` research goal — not a new lic systemd loop.

---

## Gap orchestration actions

```bash
apt-get install -y python3-yaml   # ephemeral fix — bake into image
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py    # 92 registry rows; updated_at 14:45Z
python3 scripts/swarm-gap-apply-actions.py
# wrote benchmarks/data/latest/swarm-gap-actions.json
```

| `gap_kind` | Open | Patched this cycle | Handoff |
|------------|------|--------------------|---------|
| `missing_package` | 1 (`li-line-profiler`) | `pkg-line-profiler` pending | `issue_planner` |
| `plan_debt` | 31 | sim/security backlogs re-confirmed | `plan_verifier`, `implementation_gaps` |
| `competitor_feature` | 30 | vertical stubs → sim-md backlogs | `gap_explorer`, `bench_improver` |

**Skips:** 2 studio-ui patches — `/workspace/lic-studio-ui/.../2026-05-24-studio-ui-ux-plan-loop.md` not mounted.

**Goal-orientation drift:** briefing recommends `ci_maintainer` + `security_auditor`; scorecard adds `gap_explorer` + `plan_verifier`. Supervisor should merge recommendation sources before dispatch.

---

## Control-plane fixes (orchestration only)

1. **Image:** bake `python3-yaml` — gap ingest blocked on cold containers without it.
2. **Bootstrap:** create `data/control-plane/state.json` on supervisor start.
3. **Stale gaps:** close tier-1 red registry rows when live audit `red: []`.
4. **Studio-ui:** mount `lic-studio-ui` or set `STUDIO_UI_ROOT` for gap apply.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json` → `benchmarks`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/goal-directed-agents/snapshot.json`
- `/app/data/runs/swarm_observer-1781098005289.md`

---

## Handoffs (swarm goals — no new agent ids)

| Target | Work |
|--------|------|
| `bench_improver` | Near-threshold tier-1/2 numerics (5 rows) |
| `numerics_researcher` | Yellow eigen/Newton; PH-7e SIMD matmul debt |
| `gap_explorer` | Re-ingest after verticals.toml on main; close stale red rows |
| `issue_planner` | `li-line-profiler` package seed |
| `ci_maintainer` | 28 repos missing CI on main |
| `plan_verifier` | Master-plan partial phases (2e/2f/7d/7e/8p) |
