# Orchestrator note — `swarm_coverage@performance`

**Date:** 2026-06-04  
**Agent:** `swarm_observer` (worker `e3789e79`)  
**Research goal:** `swarm_coverage`  
**Dimension:** `performance`  
**north_star_fit:** ecosystem, ai — proof-before-perf; tier-1 near-threshold + sim numerics plan debt

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (67.8), `unattended_safe: false` |
| Gap pipeline | **Green** after ingest Path fix + `python3-yaml` |
| Open gaps | **62** (30 competitor, 31 plan_debt, 1 missing_package) |
| Tier-1 performance | **0 red**; **5 near-threshold** (~1.19× cpp); **2 yellow** |
| `orch-r3` | Evidence updated — `gap-line-profiler-001` → package backlog |
| Unattended? | **No** — CP persist, CI-red wave, stale snapshot |

---

## Programmatic prep

```bash
# Fixed lic/scripts/swarm-gap-ingest.py (L229 syntax + BENCHMARKS_COMPETITIVE default)
apt-get install -y python3-yaml
python3 /workspace/lic/scripts/swarm-gap-ingest.py
python3 /workspace/lic/scripts/swarm-gap-apply-actions.py
python3 /workspace/benchmarks/scripts/ecosystem-quality-grade.py
```

**Outputs:** `lic/data/swarm-gap-registry/registry.yaml`, `benchmarks/data/latest/swarm-gap-actions.json`, `ecosystem-quality-report.json`.

---

## Performance-focused open gaps

### Near-threshold tier-1 (briefing `ecosystem_audit.benchmarks.near_threshold`)

| Bench id | ratio_vs_cpp | Handoff |
|----------|-------------:|---------|
| `num_opt_bfgs` | 1.198 | `numerics_researcher`, `bench_improver` |
| `num_integ_semi_implicit` | 1.190 | same |
| `num_integ_euler` | 1.186 | same |
| `num_integ_rk4` | 1.186 | same |
| `num_cg` | 1.185 | same |

**Yellow:** `num_eig_symmetric`, `num_root_newton` — monitor; no red-tier dispatch.

### Sim plan debt (registry → backlog apply)

| Gap id | plan_todo | Backlog patch |
|--------|-----------|---------------|
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | `sim-p1-num-dot-axpy` | `sim-algorithm-backlog.md` |
| `gap-plan-pending-sim-sim-p1-md-neighbor-cell` | `sim-p1-md-neighbor-cell` | same |
| `gap-plan-pending-sim-sim-p2-qm-dft-scf` | `sim-p2-qm-dft-scf` | same |

**Handoff:** `numerics_researcher` via `implement-goals` / sim research lane — **not** new systemd loops.

### Competitor / PH-7e rows (sample)

- `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1` — reconcile when `gap_explorer` refreshes audit (current audit shows 0 red; rows may be stale).
- `gap-hpc-kokkos-execution-memory-spaces`, `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` — proof-first SIMD matmul deferred per master plan.

---

## orch-r3 / orch-r4 status

| Todo | Status | Note |
|------|--------|------|
| `orch-r3-missing-package-sweep` | open | `gap-line-profiler-001` patched to `ecosystem-package-backlog.md` → `issue_planner` |
| `orch-r4-ui-ux-signals` | open | Defer to `swarm_coverage@ux` / `gui_ux_tester` |

---

## Control-plane gaps (blocking unattended)

1. `/app/data/control-plane/latest-report.json` + `state.json` not written in org-research Job.
2. Grader `runs_sampled: 0` — `inputs.runs_dir` points at `/workspace/li-cursor-agents/data/runs` instead of `/app/data/runs`.
3. Goal-directed snapshot stale — httpd `gap-phase2-perf-wrk-soak` still `pending` in 2026-05-30 snapshot though registry rows closed/deduped.

---

## Handoffs

| To | Why |
|----|-----|
| `bench_improver` | Near-threshold tier-1 evidence + CI-green scorecard PRs |
| `numerics_researcher` | sim-p1 dot/axpy, QM DFT plan debt; PH-7e proof path |
| `gap_explorer` | Reconcile stale red-bench registry vs audit |
| `plan_verifier` | Refresh goal-directed snapshot on host |
| `ci_maintainer` | `li-sec-agent` CI + benchmarks CI-red wave |
| `issue_planner` | `gap-line-profiler-001` package seed |

---

## Evidence paths

- Digest: `/app/data/runs/swarm_observer-1780540712764.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Briefing: `/workspace/benchmarks/data/latest/agent-briefing.json`
- Gap actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
