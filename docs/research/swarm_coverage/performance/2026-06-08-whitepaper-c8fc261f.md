# Swarm gap orchestration — performance dimension audit

**Goal id:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `c8fc261f`  
**Agent:** `swarm_observer`  
**Generated:** 2026-06-08  
**north_star_fit:** ecosystem, ai — proof → easy → fast; performance work only after provability gates  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

---

## Abstract

This pass audits Li ecosystem **performance posture** through the swarm gap orchestration lens: numerics benchmark colors, perf-related plan debt in the gap registry, and control-plane throughput for gap ingest/apply. The swarm is **degraded but recoverable** (grade C, 74.1). Tier-1 benchmarks show **no red rows** in the current briefing snapshot, but **two yellow** and **five near-threshold** numerics cases warrant `bench_improver` attention under PH-7e. Gap orchestration is **blocked** by a remediated ingest syntax error and missing PyYAML in the org-research worker image.

---

## 1. Benchmark performance signals

Source: `/workspace/benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks` (generated 2026-06-01).

| Class | IDs | ratio vs cpp (where known) | PH / route |
|-------|-----|---------------------------|------------|
| Green | 145 tier-1 rows | ≤ threshold | maintain |
| Yellow | `num_eig_symmetric`, `num_root_newton` | above yellow bar | PH-7e → `numerics_researcher` |
| Near-threshold | `num_opt_bfgs`, `num_integ_*`, `num_cg` | 1.18–1.20× | `bench_improver` watch |
| Red (registry) | `matmul_naive`, `num_gmres`, integrators, physics tier-2 | 1.35–2.00× (stale audit) | `gap_explorer` competitor_feature rows |

**Proof-before-perf:** PH-7e partial (`ArrayDotF64` for 1d `@`; SIMD matmul deferred) tracked as plan_debt — no unproved SIMD shortcuts recommended.

---

## 2. Perf plan debt (gap registry)

Open rows with direct performance impact:

| Runner / area | plan_todo_id | Status |
|---------------|--------------|--------|
| httpd | `gap-phase2-perf-wrk-soak` | pending — wrk soak vs nginx |
| httpd | `gap-phase2-streaming-wrk` | pending |
| sim | `sim-p1-num-dot-axpy` | open — BLAS-class microkernel |
| sim | `sim-p1-md-neighbor-cell` | open — MD neighbor perf |
| sim | `sim-p2-qm-dft-scf` | open — ties failing lic PR stack |
| studio-ui-ux | `studio-ux-16-palette-search-latency` | open |
| master-plan | Phase 7e, 8p partials | open — codegen + CI throughput |

Evidence: `/workspace/lic/data/swarm-gap-registry/registry.yaml`

---

## 3. Gap pipeline performance (control plane)

| Stage | Latency / blocker | Impact |
|-------|-------------------|--------|
| `swarm-gap-ingest.py` | SyntaxError @ line 229 → **fixed** | vertical stub discovery blocked since May |
| PyYAML dependency | not in container | ingest + apply cannot run |
| Last apply | 2026-05-31 | 64 open gaps stale 8+ days |
| Quality grader `runs_dir` | wrong default path | `runs_sampled=0` until `LI_CURSOR_AGENTS_ROOT=/app` |

Orchestration throughput directly affects how fast perf gaps reach implementers — this is a **meta-performance** finding for the swarm itself.

---

## 4. Recommendations

1. Merge ingest syntax fix + bake PyYAML in org-research Job.
2. Dispatch `bench_improver` on yellow + near-threshold numerics before broad SIMD work.
3. Human-triage redundant lic DFT PRs; route one stub via `sim-p2-qm-dft-scf` backlog.
4. Enable httpd wrk soak todo via implement lane (not new systemd loop).
5. Set `LI_CURSOR_AGENTS_ROOT=/app` in all worker environments.

---

## 5. Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/app/data/runs/swarm_observer-1780879148917.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r10-performance-c8fc261f.md`

---

## Validity

| Field | Value |
|-------|-------|
| grade | C (observational — blocked live ingest) |
| status | staging — publish when research-findings mounted |
