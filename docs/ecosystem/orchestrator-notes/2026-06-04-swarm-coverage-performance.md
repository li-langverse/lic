# Orchestrator note — `swarm_coverage` (performance lens)

**Date:** 2026-06-04  
**Agent:** `swarm_observer` (worker `25683566`)  
**Research goal:** `swarm_coverage` — north_star_fit: ecosystem, ai  
**Dimension:** `performance`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — ecosystem grade **D** (66.3); `unattended_safe: false` |
| Open gaps | **62** (was 64; ingest dedupe) — 13 performance-tagged |
| Gap prep | **Unblocked** — fixed `swarm-gap-ingest.py` syntax + `BENCHMARKS_COMPETITIVE` KeyError; ingest+apply @ 2026-06-04T11:28:49Z |
| Performance signal | Tier-1 red rows **absent** in live audit (`red: []`) but **140+ unknown** benches + 9 registry `benchmark-red` competitor gaps remain |
| Unattended? | **No** — failed PR CI (23), preflight failures (2), no control-plane observer state on this host |

---

## Performance gap routing (Mode B)

| Gap id | Kind | Route |
|--------|------|-------|
| `gap-benchmark-red-matmul-naive-tier1` | competitor_feature | `bench_improver` + `numerics_researcher` (PH-7e) |
| `gap-benchmark-red-num-gmres-tier1` | competitor_feature | `numerics_researcher` (PH-5b) |
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | plan_debt | sim backlog → `code_implementer` via implement goal |
| `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` | plan_debt | httpd plan loop pending — handoff `bench_improver` / human wrk gate |
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | plan_debt | studio-ui-ux plan — `gui_ux_tester` |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | plan_debt | `issue_planner` — proof-before-perf; no unsafe shortcuts |
| `gap-line-profiler-001` | missing_package | `issue_planner` — enables perf regression attribution |

**Do not** recommend new lic systemd plan loops; use `config/research-goals.yaml` + async swarm (`numerics_sota`, `swarm_coverage`).

---

## Scripts executed

```bash
export LI_LANGVERSE_ROOT=/workspace BENCHMARKS_ROOT=/workspace/benchmarks LIC_ROOT=/workspace/lic
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py && python3 scripts/swarm-gap-apply-actions.py
```

Evidence: `benchmarks/data/latest/ecosystem-quality-report.json`, `benchmarks/data/latest/swarm-gap-actions.json`, `lic/data/swarm-gap-registry/registry.yaml`.

---

## Control-plane fix (this pass)

- `lic/scripts/swarm-gap-ingest.py` line 229: unterminated string; line 227: `KeyError` on missing `BENCHMARKS_COMPETITIVE` — default to `BENCHMARKS/competitive/verticals.toml`.

---

## Handoffs

| To agent | Reason |
|----------|--------|
| `bench_improver` | Unknown catalog rows + tier-1 red registry gaps; unblock benchmarks PR #331 CI |
| `ci_maintainer` | `li-sec-agent` INCOMPLETE (404) — briefing P0 |
| `gap_explorer` | Refresh vertical ingest when `competitive/verticals.toml` lands on benchmarks main |
| `plan_verifier` | Re-enable plan_audit preflight (skipped `--skip-slow`) |
