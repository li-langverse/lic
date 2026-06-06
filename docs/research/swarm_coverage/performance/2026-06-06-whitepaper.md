# Swarm gap orchestration — performance dimension

**Goal id:** `swarm_coverage@performance`  
**Agent:** `swarm_observer`  
**Run id:** `1780748689978`  
**Worker:** `613712b5`  
**Generated:** 2026-06-06T13:05Z  
**north_star_fit:** Swarm gap orchestration — domains: ecosystem, ai; PH-7e (SIMD/parallel lowering), PH-5b (numerics parity)

**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/` (staging only — repo not mounted)

---

## Abstract

This pass audits swarm health through a **performance lens** for gap orchestration (Mode B). Live tier-1 benchmarks show **zero red rows** and **39 green**, with five near-threshold workloads led by `simd_dot` at 1.13× vs C++. The gap registry still lists eight historical `gap-benchmark-red-*` rows — orchestration drift that blocks accurate dispatch to `bench_improver`. Gap ingest was broken by a SyntaxError (fixed); gap apply remains blocked without PyYAML in the worker image. Ecosystem grade **C** (71.3) and `unattended_safe: false` reflect control-plane observability gaps and a failing metrics PR stack, not current bench regressions. Grade was **D** (62.6) before fixing `LI_CURSOR_AGENTS_ROOT` fallback to `/app` (`runs_sampled: 0` → `1`).

---

## Evidence paths

| Artifact | Path |
|----------|------|
| Quality scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Ecosystem audit | `/workspace/benchmarks/data/latest/ecosystem-audit.json` |
| Agent briefing | `/workspace/benchmarks/data/latest/agent-briefing.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Orchestrator note | `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r6-performance-bench-handoffs.md` |
| Observer digest | `/app/data/runs/swarm_observer-1780748689978.md` |

---

## Benchmark posture (performance)

### Tier-1 summary

- **Green:** 39 workloads at or below 1.2× C++ reference
- **Red:** none in live audit (2026-06-06)
- **Near threshold:** `simd_dot` (1.1279×), `md_init_fcc_mb`, `md_longrange_ewald`, `md_integrator_verlet`, `md_neighbor_cell_list` (~1.01–1.02×)
- **Unknown:** 109 catalog IDs without measured oracle (blocks honest competitive matrix)

### Master-plan performance debt

Registry row `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` tracks partial SIMD lowering: 1d `float` `@` via `ArrayDotF64`; **SIMD matmul deferred**. This is the canonical proof-before-perf path — perf work must not bypass Lean policy.

---

## Gap orchestration findings

1. **Ingest blocked (fixed):** `swarm-gap-ingest.py:229` unterminated string — Path fallback for `verticals.toml` corrected.
2. **Apply blocked:** `swarm-gap-apply-actions.py` requires PyYAML — not installed in org-research worker.
3. **Registry stale vs audit:** Open `gap-benchmark-red-*` rows contradict `benchmarks.red: []` — ingest should auto-close when audit green.
4. **Dispatch gap:** Briefing recommends `ci_maintainer`, `security_auditor`, `pr_merger` — not `bench_improver` despite near-threshold SIMD/MD signals and open perf registry rows.

---

## Recommendations

1. Merge ingest fix; install PyYAML; re-run ingest + apply before next `swarm_coverage` cadence (6h).
2. Add scorecard rule: when `benchmark_red_count=0`, flag open `gap-benchmark-red-*` as registry drift (severity medium).
3. Dispatch `bench_improver` on near-threshold `simd_dot` + MD cluster via research lane handoff from `swarm_observer`.
4. Fix `ecosystem-quality-grade.py` agents root fallback (`/app`) so `swarm_execution` samples runs in container layout.
5. Consolidate failing benchmarks grade-refresh PRs (#371–#378) into one CI-green commit.

---

## Validity

| Grade | Rationale |
|-------|-----------|
| **B** | Deterministic audit artifacts; ingest fix verified locally; apply and research-findings publish deferred |
