# Swarm gap orchestration — performance lens

**Goal:** `swarm_coverage` · **Dimension:** performance · **Worker:** `1ebca9c6`  
**Generated:** 2026-06-07T07:20:00Z  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/` (staging copy below)

## Abstract

This whitepaper audits swarm gap orchestration through a **performance** lens: benchmark posture, perf-related plan debt, and control-plane throughput for closing PH-7e/PH-5b gaps. The swarm is **degraded** (grade D, 60.9) and not unattended-safe. The primary orchestration bottleneck this cycle was **broken gap ingest** (Python syntax + missing `BENCHMARKS_COMPETITIVE` fallback), now self-healed; the primary *product* perf debt remains **httpd wrk soak**, **tier-1 red microbenches**, and **six stopped goal runners**.

## north_star_fit

| Domain | PH ids | Rationale |
|--------|--------|-----------|
| ecosystem | — | Swarm must route perf gaps without human triage |
| ai | — | Agent loops need profiling (`gap-line-profiler-001`) |
| HPC/numerics | PH-5b, PH-7e | GMRES, matmul, integrators, SIMD lowering |
| CI throughput | Phase 8p | Parallel compile gates perf regression CI |

Pillar order respected: no perf shortcuts that bypass proof (Phase 7e partial is documented, not bypassed).

## Benchmark posture (2026-06-07)

Source: `benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks`

| Signal | Count / detail |
|--------|----------------|
| Green | 145 |
| Red (tier-1) | 0 in latest audit snapshot |
| Yellow | `num_eig_symmetric`, `num_root_newton` |
| Near threshold (~1.18–1.20× cpp) | `num_opt_bfgs`, `num_integ_*`, `num_cg` |

**Interpretation:** Li is competitive on most tier-1/2 rows but lacks headroom on symmetric eig/root-finding and several integrator/optimizer kernels. Swarm should prioritize `bench_improver` + `numerics_researcher` handoffs from registry rows, not duplicate dashboard UI PRs.

## Performance-critical open gaps (top 10)

From `lic/data/swarm-gap-registry/registry.yaml` + `benchmarks/data/latest/swarm-gap-actions.json`:

1. **httpd wrk soak** — `gap-phase2-perf-wrk-soak` (runner httpd, pending)  
2. **httpd streaming wrk** — `gap-phase2-streaming-wrk`  
3. **sim dot/axpy** — `sim-p1-num-dot-axpy` → `sim-algorithm-backlog.md`  
4. **matmul_naive 1.73×** — `gap-benchmark-red-matmul-naive-tier1`  
5. **num_gmres 1.68×** — `gap-benchmark-red-num-gmres-tier1`  
6. **Phase 7e SIMD matmul** — master-plan partial  
7. **Phase 8p parallel compile** — CI throughput  
8. **li-line-profiler package** — agent/HPC loop observability  
9. **orch-r3 missing-package sweep** — meta orchestration debt  
10. **verticals.toml on benchmarks main** — blocks competitive ingest (`gap-infra-verticals-toml-missing-benchmarks-main`)

## Control-plane performance metrics

| Metric | Value | Evidence |
|--------|-------|----------|
| Org-research `swarm_coverage@performance` duration (prior runs) | 546s–2291s | `org-research-audit.jsonl` |
| Gap ingest latency (this run, post-fix) | ~160ms | shell timing |
| Ecosystem grade regen | ~32ms | `ecosystem-quality-grade.py` |
| Runs sampled for swarm_execution | 0 | `LI_CURSOR_AGENTS_ROOT=/app` sparse `data/runs/` |
| Goal runners live | 0 / 9 | `goal-directed-agents/snapshot.json` (stale 2026-05-30) |

**Recommendation:** Bake `python3-yaml` + set `BENCHMARKS_ROOT`/`LIC_ROOT` on org-research Jobs; persist control-plane state each supervisor tick so observer does not re-bootstrap.

## Handoff matrix (performance gaps)

| Agent | Gaps routed |
|-------|-------------|
| `bench_improver` | httpd wrk/streaming, near-threshold integrators |
| `numerics_researcher` | matmul_naive, num_gmres, sim dot/axpy, PH-7e research |
| `plan_verifier` | Phase 7e/8p master-plan debt, snapshot refresh |
| `ci_maintainer` | 14 repos missing CI — blocks perf regression gates |
| `issue_planner` | `gap-line-profiler-001`, package backlog |
| `pr_merger` | lip#52 — unblocks deploy-pages perf pipeline |

## Conclusion

Gap orchestration **infrastructure** is unblocked after ingest fix; **product performance** debt remains in httpd soak gates, tier-1 competitor rows, and stopped sim/httpd runners. Swarm can run brief unattended cycles for merge/CI lanes only; full perf gap closure requires runner restart + `bench_improver` dispatch.

## References

- `benchmarks/data/latest/ecosystem-quality-report.json`  
- `benchmarks/data/latest/swarm-gap-actions.json`  
- `lic/data/swarm-gap-registry/registry.yaml`  
- `lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r9-performance-gap-handoffs-1ebca9c6.md`  
- Vision: [vision-and-roadmap.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md)  
