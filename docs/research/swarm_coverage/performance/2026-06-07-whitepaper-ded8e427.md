# Swarm gap orchestration — performance dimension

**Goal id:** `swarm_coverage`  
**Agent:** `swarm_observer`  
**Worker:** `ded8e427`  
**Run id:** `1780806307240`  
**Generated:** 2026-06-07T04:49Z  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`  
**north_star_fit:** ecosystem, ai — performance after proof (PH-5b, PH-7e)

---

## Abstract

This pass audits Li swarm health through a **performance lens** for the `swarm_coverage` research goal. The ecosystem scorecard refreshed to **grade D (60.9)** with `unattended_safe: false`. Numerics posture is **recovering**: zero tier-1 red rows, two yellow, five near-threshold. However, **64 open swarm-gap registry rows** remain unapplied because the gap ingest/apply pipeline is blocked by missing PyYAML and a recurring ingest syntax defect (remediated locally). Performance work must route through existing swarm agents — `bench_improver`, `numerics_researcher`, `plan_verifier` — not new systemd plan loops.

---

## 1. Benchmark posture (2026-06-07)

Source: `/workspace/benchmarks/data/latest/ecosystem-audit.json`

| Class | Count | Examples |
|-------|-------|----------|
| Red | 0 | — |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near threshold (>1.18× cpp) | 5 | `num_opt_bfgs` (1.20×), integrators, `num_cg` |
| Green | 145 | — |

**Interpretation:** Li numerics are within striking distance of the ≤1.2× cpp tier-1 goal for several kernels, but registry still lists historical red-class gaps (`matmul_naive` 1.73×, `num_gmres` 1.68×) that need reconciliation against current audit data — a **gap_explorer** ingest refresh task.

---

## 2. Performance-linked registry gaps

Source: `/workspace/lic/data/swarm-gap-registry/registry.yaml`

| Category | Open count | Top priority ids |
|----------|------------|------------------|
| competitor_feature (bench/HPC) | 30 | `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1`, `gap-hpc-kokkos-execution-memory-spaces` |
| plan_debt (perf runners) | 31 | sim dot/axpy, md neighbor-cell, studio palette latency, Phase 7e/8p |
| missing_package | 3 | `gap-line-profiler-001` (HPC profiling) |

**Pillar order respected:** Phase 7e SIMD and bench improvements assume proof certificates (`lic build`) — no `unsafe` shortcuts.

---

## 3. Swarm orchestration performance

| Metric | Value | Evidence |
|--------|-------|----------|
| Gap apply last run | 2026-05-31 | `swarm-gap-actions.json` |
| Ingest status | Blocked (PyYAML) | worker stderr |
| runs_sampled | 0 | path mismatch in grade script |
| Goal-directed runners live | 0/9 | snapshot 2026-05-30 |

**Orchestration debt directly impacts performance velocity:** stale registry → wrong dispatch order → bench_improver idle while near-threshold kernels age.

---

## 4. Recommendations

1. **Unblock gap pipeline** — PyYAML in worker image + merge ingest fix.
2. **Dispatch bench_improver** on near-threshold ids before they regress to red.
3. **Refresh registry** — close bench gaps where audit shows green/yellow; dedupe stale red rows.
4. **Sim/httpd plan todos** — hand `sim-p1-num-dot-axpy`, `gap-phase2-perf-wrk-soak` to numerics/httpd research lanes via swarm goals, not lic systemd loops.
5. **Fix runs_dir** — enable swarm_execution dimension scoring for error-rate self-heal.

---

## 5. Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r6-performance-gap-handoffs-ded8e427.md`
- `/app/data/runs/swarm_observer-1780806307240.md`

---

## Validity

| Field | Value |
|-------|-------|
| status | staging |
| validity_grade | provisional |
| domains | ecosystem, ai |
| agent | swarm_observer |
