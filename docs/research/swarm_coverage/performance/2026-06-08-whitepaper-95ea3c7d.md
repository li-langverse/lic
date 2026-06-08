# Swarm coverage — performance dimension

**Goal:** `swarm_coverage`  
**Worker:** `95ea3c7d`  
**Date:** 2026-06-08  
**north_star_fit:** ecosystem, ai — proof → easy → fast (PH-7e, PH-5b)  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

---

## Abstract

Meta-audit of the Li agent swarm under the **performance** lens for gap orchestration. The ecosystem quality scorecard dropped to **D (65.8)** with `unattended_safe: false`. Performance pressure is moderate at the bench layer (no tier-1 red in live audit snapshot) but elevated in the **gap registry** (8 historical tier-1 red rows) and **near-threshold** numerics (5 rows within ~1.20× of cpp). Gap apply automation is blocked by a missing PyYAML dependency; control-plane observer state is not persisted in the current deploy.

---

## Method

1. Regenerated `ecosystem-quality-report.json` via `benchmarks/scripts/ecosystem-quality-grade.py`.
2. Compared `agent-briefing.json` recommended agents vs `heap_plan.flat_tasks`.
3. Read `swarm-gap-registry/registry.yaml` and `swarm-gap-actions.json` for performance-class gaps.
4. Cross-referenced `ecosystem-audit.json` benchmark posture (yellow, near_threshold).
5. Attempted programmatic gap ingest/apply per swarm_coverage Mode B.

---

## Findings

### Bench posture (live audit)

| Class | Count | Examples |
|-------|-------|----------|
| Green | 145 | tier-1/2 harness majority |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold | 5 | BFGS, integrators, CG (~1.18–1.20× cpp) |
| Red (live) | 0 | — |

Source: `ecosystem-audit.json` (generated 2026-06-01).

### Gap registry (performance-tagged)

- **30** `competitor_feature` open — includes 8 `gap-benchmark-red-*` tier-1 rows and HPC library parity (Kokkos, PETSc, FFTW, hypre).
- **31** `plan_debt` open — includes PH-7e SIMD partial, PH-8p parallel compile, sim numerics todos, httpd wrk soak.
- Performance orchestration must route through existing research goals (`numerics_sota`, `md_sim_algorithms`, `scientific_distributed_computing`) and `bench_improver` — not retired systemd sim loops.

### Swarm execution blind spot

`runs_sampled: 0` in regenerated scorecard — fresh container has no historical run JSON under `/app/data/runs`. Prior cycle reported 25% error rate over 24 terminal runs; error classification deferred.

### Automation blockers affecting perf loops

| Blocker | Impact on performance work |
|---------|---------------------------|
| PyYAML missing | Gap ingest/apply cannot refresh bench-red backlog patches |
| Control-plane state missing | Observer cannot auto-retry `bench_improver` / `numerics_researcher` |
| 6 stopped goal runners | sim/httpd/studio plan perf todos stall |

---

## Recommendations

1. **Dispatch `bench_improver`** on near-threshold rows before they flip red (BFGS, integrators).
2. **Enable PyYAML** in agent runtime; re-run ingest + apply to sync 64-gap backlog.
3. **Bootstrap observer state** so perf-agent error streaks trigger auto-retry (budget 3).
4. **Merge `verticals.toml` to benchmarks main** (`gap-infra-verticals-toml-missing-benchmarks-main`) for honest stub ingest.
5. **Handoff `numerics_researcher`** on PH-7e plan_debt + HPC competitor gaps with proof certificate discipline.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780941261022.md`

---

## Deferred

- Publish copy to `research-findings` repo index (out of band).
- Re-sample agent error runs when run corpus populated.
- Full wrk soak gate for httpd (`gap-phase2-perf-wrk-soak`) — pending human/ci capacity.
