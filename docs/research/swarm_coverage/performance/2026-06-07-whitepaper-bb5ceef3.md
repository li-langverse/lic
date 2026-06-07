# Swarm coverage — performance dimension whitepaper (staging)

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `bb5ceef3`  
**Generated:** 2026-06-07T23:20Z  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

## Thesis

Swarm gap orchestration for **performance** is blocked at the **control-plane boundary**, not LLM throughput. The highest-leverage fixes are: (1) unblock gap ingest/apply, (2) align `runs_dir` for observer scoring, (3) route PH-7e numerics and httpd wrk soak via existing goals — not new systemd loops.

## Benchmark posture (proof → fast)

| Tier | Bench IDs | Ratio vs C++ | Route |
|------|-----------|--------------|-------|
| Yellow | `num_eig_symmetric`, `num_root_newton` | >1.15× | `bench_improver` + `numerics_researcher` (PH-7e) |
| Near-threshold | `num_opt_bfgs`, `num_integ_*`, `num_cg` | 1.18–1.20× | `autoresearch` after yellow closed |
| Green | 145 benches | ≤1.15× | maintain |

Evidence: `/workspace/benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks`.

## Gap registry performance rows

- **httpd:** `gap-phase2-perf-wrk-soak` — full wrk soak vs nginx; pending in goal-directed snapshot.
- **competitor_feature:** 10+ `gap-benchmark-red-*` tier-1 rows (matmul, GMRES, integrators, cloth, orbit, schrodinger).
- **HPC class:** Kokkos, PETSc, hypre, FFTW roofline — route via `scientific_distributed_computing` / `physics_sim` research goals.

## Observer performance metrics (this environment)

| Signal | Value | Impact |
|--------|-------|--------|
| `runs_sampled` | 0 | Grader cannot score swarm_execution |
| Gap ingest | Was SyntaxError; fixed this pass | Registry refresh restored |
| PyYAML | Ephemeral pip only | Apply fails on cold pods |
| Ecosystem grade | 65.8 (D) | `unattended_safe=false` |
| Triage fail rate (24h) | 0% | Issue lane healthy |

## Recommendations

1. Merge lic PR fixing `swarm-gap-ingest.py` Path/env fallback (orch-r13).
2. Bake PyYAML in worker; set `LI_CURSOR_AGENTS_ROOT=/app`.
3. Dispatch `bench_improver` on yellow numerics before near-threshold autoresearch.
4. Handoff httpd `gap-phase2-perf-wrk-soak` to implement lane (proof gates intact).

**north_star_fit:** ecosystem orchestration + PH-7e numerics — provability before perf tuning.
