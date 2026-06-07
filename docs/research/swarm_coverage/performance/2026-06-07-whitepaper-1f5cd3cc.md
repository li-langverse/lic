# Swarm gap orchestration — performance dimension

**Goal id:** `swarm_coverage`  
**Dimension:** `performance`  
**Agent:** `swarm_observer`  
**Worker:** `1f5cd3cc`  
**Generated:** 2026-06-07T17:20:11Z  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Pillar order respected:** proof → easy → fast (no unproved perf shortcuts recommended)

---

## Abstract

This whitepaper documents the **performance lens** of swarm gap orchestration for the 2026-06-07 observer pass. The ecosystem scorecard grades **D** (66.8) with `unattended_safe: false`. The gap ingest/apply pipeline is **blocked**, preventing backlog reconciliation for performance-critical todos (httpd wrk soak, benchmark-red registry rows, yellow numerics). Swarm stability metrics improved (0% triage fail rate), but orchestration observability is blind (`runs_sampled=0`) due to path misconfiguration.

---

## 1. Ecosystem performance posture

Source: `/workspace/benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks`

| Class | Count | Notable ids |
|-------|-------|-------------|
| Red | 0 | — |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near tier-1 (≥1.18× cpp) | 5 | `num_opt_bfgs`, `num_integ_semi_implicit`, `num_integ_euler`, `num_integ_rk4`, `num_cg` |
| Green | 145 | — |

**Interpretation:** No tier-1 red regressions in the current audit snapshot, but linalg eigen/root solvers remain yellow (PH-7e partial surface). Five integrator/optimizer microbenches approach the red threshold — early warning for pillar-3 work **after** proof certificates hold.

---

## 2. Gap registry — performance-class rows

Source: `/workspace/lic/data/swarm-gap-registry/registry.yaml`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`

### 2.1 httpd wrk soak (plan_debt)

- **Todo:** `gap-phase2-perf-wrk-soak`
- **Runner:** `httpd` (goal-directed snapshot)
- **Status:** pending; prior agent exit **124** (timeout)
- **Gate:** `check-tier5-perf-wrk-soak.sh` with `HTTPD_BENCH_SKIP_TIMING=0`
- **Orchestration:** Route via httpd goal runner on agents control plane — not a new lic systemd loop

### 2.2 Benchmark-red competitor gaps (competitor_feature)

Representative open rows (30 total in registry):

| Gap id | Title | vs cpp |
|--------|-------|--------|
| `gap-benchmark-red-matmul-naive-tier1` | matmul_naive | ~1.73× |
| `gap-benchmark-red-num-gmres-tier1` | num_gmres | ~1.68× |
| `gap-benchmark-red-num-integ-euler-tier1` | num_integ_euler | ~1.40× |
| `gap-benchmark-red-orbit-two-body-tier1` | orbit_two_body | ~1.69× |

**Handoff:** `bench_improver` for harness/measurement; `numerics_researcher` for proved algorithm improvements.

### 2.3 PH-7e codegen catalog

- **Gap:** `gap-competitor-pure-li-ph7e-catalog`
- **Link:** Increase pure_li catalog variants for SIMD/parallel lowering proof
- **Constraint:** Matrix `@` and SIMD matmul remain deferred per master plan — no unsafe acceleration

---

## 3. Orchestration performance (control plane)

| Metric | Value | Evidence |
|--------|-------|----------|
| Scorecard age (pre-refresh) | 7 days stale | `ecosystem-quality-report.json` was 2026-05-31 |
| Gap actions age | 7 days stale | `swarm-gap-actions.json` @ 2026-05-31 |
| Runs sampled | 0 | Wrong `runs_dir`; set `LI_CURSOR_AGENTS_ROOT=/app` |
| Ingest latency | ∞ (failed) | SyntaxError blocks registry refresh |
| Triage fail rate (24h) | 0% | `org-swarm-stability-audit.jsonl` @ 17:00Z |

**Recommendation:** Treat gap pipeline unblock as **P0 orchestration perf** — stale registry blocks all downstream bench/implement agents.

---

## 4. Swarm routing table (performance)

| Priority | Agent | Target |
|----------|-------|--------|
| 1 | `pr_merger` | lip#52 (low-risk deps) |
| 2 | `ci_maintainer` | 14 repos missing CI |
| 3 | `bench_improver` | Yellow + near-threshold rows |
| 4 | `numerics_researcher` | PH-7e eig/root; proved fixes only |
| 5 | `gap_explorer` | Reconcile 64 open gaps post-unblock |

---

## 5. Validity

| Field | Value |
|-------|-------|
| `validity_grade` | **B-** — audit data fresh post-refresh; gap apply not re-run |
| `status` | staging |
| `artifacts` | this file + orchestrator note + observer digest |

**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/` (deferred — repo not mounted)

---

## References

1. `/app/data/runs/swarm_observer-1780850919370.md`
2. `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-07-swarm-coverage-performance-1f5cd3cc.md`
3. `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
4. `/workspace/lic/data/goal-directed-agents/snapshot.json`
5. `docs/ecosystem/research-verticals.md` — numerics vertical + `bench_improver` / `autoresearch` roles
