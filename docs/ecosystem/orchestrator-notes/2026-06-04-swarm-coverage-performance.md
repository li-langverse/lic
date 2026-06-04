# Orchestrator note — `swarm_coverage@performance`

**Date:** 2026-06-04  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Worker:** `90898f49`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai; performance lens (PH-7e, PH-5b)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — ecosystem grade **D** (67.8); `unattended_safe: false` |
| Control plane | MCP Postgres **unreachable**; disk `state.json` / `latest-report.json` **missing** |
| Gap pipeline | Ingest **syntax fixed** this pass; **PyYAML missing** in Job image blocks live ingest/apply |
| Open gaps | **64** (`competitor_feature`: 30, `plan_debt`: 31, `missing_package`: 1 open in registry) |
| Performance lens | **0 tier-1 red** in live audit; **5 near-threshold** + **2 yellow** numerics rows |
| Unattended? | **No** — infra + gap-script deps + 12 CI-red PRs |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `/workspace/benchmarks/data/latest/agent-briefing.json`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`, `/workspace/lic/data/swarm-gap-registry/registry.yaml`.

---

## Performance dimension — benchmark posture

Live audit (`ecosystem-audit.json` via briefing, generated 2026-06-01):

| Class | IDs | Ratio vs cpp | Handoff |
|-------|-----|--------------|---------|
| **Yellow** | `num_eig_symmetric`, `num_root_newton` | >1.15x threshold | `numerics_researcher` → `bench_improver` (proof-first) |
| **Near threshold** | `num_opt_bfgs` | 1.1978x | `bench_improver` (PH-7e) |
| **Near threshold** | `num_integ_semi_implicit`, `num_integ_euler`, `num_integ_rk4` | ~1.19x | `numerics_researcher` (PH-5b integrators) |
| **Near threshold** | `num_cg` | 1.1848x | `numerics_researcher` (PH-5b) |

Registry still lists **tier-1 red** rows from prior scorecard (`gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1`, etc.) — reconcile after `gap_explorer` refresh; do not auto-close without fresh harness evidence.

**Physics-codegen CI wave:** benchmarks PRs #306–#313 failing CI block tier-2 kernel evidence — human triage before merge (`ci_maintainer` + `bug_fixer`).

---

## Open gap reconciliation (performance-relevant)

| Gap id | Kind | Action | Route |
|--------|------|--------|-------|
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | plan_debt | Patched → `sim-algorithm-backlog.md` | `numerics_researcher` / `md_sim_algorithms` goal |
| `gap-plan-pending-sim-sim-p1-md-neighbor-cell` | plan_debt | Patched → sim backlog | `numerics_researcher` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | plan_debt | Master-plan partial — SIMD matmul deferred | `issue_planner` (PH-7e); no perf shortcut |
| `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` | plan_debt | CI throughput partial | `ci_maintainer` |
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | plan_debt | UI perf gate pending | `gui_ux_tester` / `ui_ux_quality` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | plan_debt | GPU recovery perf | `gui_ux_tester` |
| `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` | plan_debt | wrk soak vs nginx | `server_platform` research + httpd runner (not new systemd loop) |
| `gap-line-profiler-001` | missing_package | Open — line profiler seed | `issue_planner` → `ecosystem-package-backlog.md` |

**Do not** recommend `install-goal-plan-loop-systemd.sh` — route via swarm goals (`numerics_sota`, `simulation_techniques`, `server_platform`) and existing runner backlogs.

---

## Scripts / prep status

| Step | Status | Detail |
|------|--------|--------|
| `ecosystem-quality-grade.py` | ✅ | Regenerated 2026-06-04T01:58Z → D / 67.8 |
| `swarm-gap-ingest.py` | ⚠️ | Syntax fixed (`scripts/swarm-gap-ingest.py` L226–238); **PyYAML required** in container |
| `swarm-gap-apply-actions.py` | ⚠️ | Blocked on PyYAML |
| Programmatic observer tick | ❌ | No CP state on disk; DB down |

---

## Handoffs (cite north_star_fit)

1. **`bench_improver`** — near-threshold tier-1 rows; proof-before-perf (PH-7e).
2. **`numerics_researcher`** — `sim-p1-num-dot-axpy`, integrator/CG yellow rows (PH-5b).
3. **`gap_explorer`** — refresh tier-1 red registry rows vs live audit; close stale `gap-benchmark-red-*` if harness green.
4. **`ci_maintainer`** — benchmarks #306–#313 CI; 1 repo missing CI on main.
5. **`plan_verifier`** — enable `plan_audit` preflight (currently `--skip-slow`).

Whitepaper digest (performance): defer publish until `research-findings` repo mounted → `whitepapers/2026-06/swarm_coverage/performance/`.
