# Orchestrator note — `orch-r7-performance-handoffs`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Worker:** `fd99f4e9`  
**Research goal:** `swarm_coverage@performance`  
**north_star_fit:** ecosystem, ai — PH-5b bench honesty, PH-7e SIMD lowering (proof-before-perf)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (60.9)**; `unattended_safe: false` |
| Gap registry | **64 open** (unchanged); ingest L229 syntax **fixed**; apply **blocked** (PyYAML) |
| Performance signal | 111 `unknown` benchmarks; 5 `near_threshold`; 8 tier-1 `gap-benchmark-red-*` |
| Worst near-threshold | `simd_dot` **1.1279×** cpp |
| Unattended? | **No** — gap pipeline + CI failure wave + CP observer blind |

---

## Performance gap routing

| Registry / audit id | Backlog / plan | Handoff agent | PH |
|---------------------|----------------|---------------|-----|
| `simd_dot` (near 1.13×) | `sim-p1-num-dot-axpy` (patched pending) | `numerics_researcher`, `bench_improver` | PH-7e, PH-5b |
| `md_init_fcc_mb`, `md_longrange_ewald`, `md_integrator_verlet`, `md_neighbor_cell_list` | sim-algorithm backlog | `numerics_researcher` / `md_sim_algorithms` | PH-5b |
| `gap-benchmark-red-matmul-naive-tier1` | — (registry open) | `bench_improver`, `autoresearch` | PH-7e |
| `gap-benchmark-red-num-gmres-tier1` | — | `numerics_researcher` | PH-5b |
| `gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe` | master plan partial | `proof_gap_researcher` → then perf | PH-7e |
| `gap-competitor-pure-li-ph7e-catalog` | pure_li catalog variants | `numerics_researcher` | PH-7e |
| 111 `unknown` benchmark ids | catalog stub-honest | `gap_explorer`, `issue_planner` | PH-5b |

**Do not** spawn retired `sim` systemd plan loops — route via research lane goals (`md_sim_algorithms`, `numerics_sota`) per `docs/ecosystem/swarm-architecture.md`.

---

## Scripts (this pass)

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# overall_score=60.9 grade=D unattended_safe=False

cd /workspace/lic
python3 scripts/swarm-gap-ingest.py
# BEFORE: SyntaxError L229 — FIXED (Path fallback)
# AFTER:  PyYAML required — blocked

python3 scripts/swarm-gap-apply-actions.py
# PyYAML required — blocked
```

---

## Control-plane fixes required

1. **Merge** ingest L229 fix on `lic` (repeated SyntaxError across observer cadence).
2. **Bake** `python3-yaml` in org-research worker image (`li-cursor-agents` deploy).
3. **Persist** `/app/data/control-plane/latest-report.json` + `state.json` when Supabase absent.
4. **Grader** `runs_dir` fallback → `/app/data/runs` (this container mount).

---

## Swarm dispatch order

| Priority | Agent | Reason |
|----------|-------|--------|
| P0 | `pr_merger` | lip#52 merge-approved + gate-ready |
| P0 | `ci_maintainer` | 14 repos missing CI; 38 failed-CI PRs |
| P1 | `bench_improver` | tier-1 red + near-threshold SIMD/MD |
| P1 | `numerics_researcher` | `sim-p1-num-dot-axpy`, MD near-threshold |
| P2 | `gap_explorer` | 64 open gaps after PyYAML unblocked |
| P2 | `plan_verifier` | refresh plan_debt snapshot |

Research goal row unchanged in `li-cursor-agents/config/research-goals.yaml` → `swarm_coverage` (cadence 6h, priority 10).

---

## Human-only

- PH-7e codegen / `trusted.lean` — no auto-merge.
- Pick one benchmarks GPU chip-picker PR (#400–409); close duplicates.
- Tier-1 red bench fixes require proved lowering — no `unsafe` shortcuts.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/goal-directed-agents/snapshot.json`
- `/app/data/runs/swarm_observer-1780772999482.md`
