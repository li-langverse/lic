# Orchestrator note — `orch-r5-performance-gap-orchestration`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `7b620e59`  
**Research goal:** `swarm_coverage` @ `performance`  
**north_star_fit:** ecosystem, ai — proof → easy → fast; PH-5b/7e bench routing

---

## Executive summary

| Field | Value |
|---|---|
| Swarm posture | **Degraded** — grade **D (63.9)**; `unattended_safe: false` |
| Gap apply pipeline | **Stale** — last apply 2026-05-31; ingest SyntaxError + PyYAML block refresh |
| Performance signals | 2 yellow benches, 5 near-threshold (~1.18–1.20× vs C++), 30 open `competitor_feature` rows |
| `orch-r5` focus | Route performance gaps via research goals + existing backlogs — no product patches in this note |
| Unattended? | **No** — control-plane state missing; gap scripts fail until infra fixes land |

---

## Performance gap reconciliation

### Audit → registry mapping

| Signal | Ratio / status | Registry / backlog target | Handoff |
|---|---|---|---|
| `num_eig_symmetric` | yellow | No dedicated row — track under PH-7e | `bench_improver` → `numerics_sota` |
| `num_root_newton` | yellow | No dedicated row | `bench_improver` → `numerics_sota` |
| `num_opt_bfgs` | 1.20× near-threshold | Watch; no red row yet | `bench_improver` |
| `num_integ_*`, `num_cg` | ~1.18–1.19× | Overlap `gap-benchmark-red-num-integ-euler-tier1` etc. | `numerics_researcher` |
| `sim-p1-num-dot-axpy` | plan_debt open | Patched → `sim-algorithm-backlog.md` (2026-05-31) | `numerics_researcher` / sim implement lane |
| Phase 7e SIMD partial | plan_debt | `gap-plan-debt-lic-master-plan-phase-7e-*` | `plan_verifier` → human issue |
| `studio-ux-16-palette-search-latency` | plan_debt open | studio-ui-ux plan loop todo | `gui_ux_tester` via `ui_ux_quality` |

### Competitor_feature performance rows (sample — all remain open)

- `gap-benchmark-red-matmul-naive-tier1` (1.73×) → `bench_improver`, `numerics_researcher`
- `gap-benchmark-red-num-gmres-tier1` (1.68×) → `numerics_researcher`
- `gap-competitor-pure-li-ph7e-catalog` → codegen proof variants before perf claims
- `gap-hpc-kokkos-*`, `gap-hpc-openmp-*` → research issues; defer perf until proof surface exists

**Rule:** proof-before-perf — no `unsafe`/unproved shortcuts on bench closure.

---

## Scripts (attempted)

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# wrote data/latest/ecosystem-quality-report.json — D 63.9

cd /workspace/lic
python3 scripts/swarm-gap-ingest.py      # FAIL SyntaxError:229
python3 scripts/swarm-gap-apply-actions.py  # FAIL PyYAML required
```

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|---|---|
| `gap_explorer` | Refresh competitor_feature signals after ingest fix |
| `bench_improver` | Yellow + near-threshold numerics (PH-5b/7e) |
| `numerics_researcher` | `numerics_sota`, `md_sim_algorithms` — dot/axpy, integrator gaps |
| `plan_verifier` | Master-plan Phase 7e/8p partial rows |
| `issue_planner` | Human-gated perf issues from registry handoffs |

Research goals unchanged in `li-cursor-agents/config/research-goals.yaml` — `swarm_coverage` stays on `swarm_observer`.

---

## Registry plan-debt rows (swarm-observer runner)

- `orch-r3-missing-package-sweep` — sweep done 2026-05-31; close on next ingest when snapshot updated
- `orch-r4-ui-ux-signals` — parallel UX dimension run 2026-06-07
- **`orch-r5-performance-gap-orchestration`** — this note is completion evidence for performance dimension

---

## Human-only

- Merge `lic#1024` (ingest fix) before expecting automated gap refresh
- PH-7e SIMD / matmul product work — human review on `lic` main
- Governance PRs (`lic#1021`, `#1014`) — no auto-merge

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780834718097.md`
