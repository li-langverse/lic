# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-06  
**Agent:** `swarm_observer` (worker `8c52c6db`)  
**Research goal:** `swarm_coverage` @ dimension **`ux`**  
**north_star_fit:** ecosystem + ai — UX gap orchestration via registry/backlog/handoffs (no lic product code)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — ecosystem grade **D** (62.6), `unattended_safe: false` |
| UX registry drift | **3 open `plan_debt` rows stale** vs `studio-ui-ux-plan-loop/state.json` |
| `ui_ux` taxonomy | No dedicated `ui_ux` gap_kind rows; UX signals live under `plan_debt` + benchmark `unknown` |
| Apply pipeline | **Blocked** — `swarm-gap-ingest.py` L229 syntax fixed this run; PyYAML still missing in runner |
| Unattended? | **No** — 34 failing PRs, 6 phantom CI repos, gap apply cannot re-run |

---

## UX dimension audit

### Studio UI plan debt (registry vs live state)

| Gap id | Registry | Live state (`lic/data/studio-ui-ux-plan-loop/state.json`) | Action |
|--------|----------|-----------------------------------------------------------|--------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | open | **completed** (`studio-ux-16-palette-search-latency`) | Close registry row on next ingest after snapshot refresh |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | open | **completed** (`studio-ux-17-gpu-fail-recovery`) | same |
| `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` | open | This note completes orch-r4 scope | Close after `plan_verifier` snapshot sync |

**Evidence:** `lic/data/swarm-gap-registry/registry.yaml`, `lic/data/studio-ui-ux-plan-loop/state.json`

### Benchmark UX coverage (unknown rows)

Eight `viz_*` workloads remain **`unknown`** in ecosystem audit (no oracle / no harness):

- `viz_colormap`, `viz_decimate`, `viz_inspector_panels`, `viz_linked_views`
- `viz_marching_cubes`, `viz_pipeline_graph`, `viz_resample`

**Evidence:** `benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.benchmarks.unknown`

**Route:** research goal `ui_ux_quality` → agent `gui_ux_tester` → handoff `issue_planner` for stub-honest catalog rows (do not invent benchmarks without proof gates).

### Swarm UX orchestration gaps

| Symptom | Evidence | Severity |
|---------|----------|----------|
| Gap ingest syntax error blocked vertical stub ingest | `lic/scripts/swarm-gap-ingest.py` L229 | high — **fixed this run** |
| Gap apply requires PyYAML | `swarm-gap-apply-actions.py` stderr | high |
| Goal-directed snapshot stale (2026-05-30) | `lic/data/goal-directed-agents/snapshot.json` | medium |
| Control-plane observer state missing | `/app/data/control-plane/state.json` ENOENT | medium |

---

## Swarm routing (no new loops)

| Work | Route | Goal / handoff |
|------|-------|----------------|
| Close stale studio-ui registry rows | `plan_verifier` | refresh snapshot → re-ingest |
| Viz benchmark honesty | `gui_ux_tester` | `ui_ux_quality` |
| Studio palette/GPU UX regressions | `code_implementer` via studio-ui plan | PH-UX-04, PH-UX-08 |
| Metrics grade refresh | `ecosystem_grader` | benchmarks PR stack |

**Do not** recommend `install-goal-plan-loop-systemd.sh`. Studio UX runs on agents control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Scripts

```bash
# Fixed ingest (PyYAML still required for apply)
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
```

**Apply deferred:** `python3 scripts/swarm-gap-apply-actions.py` — PyYAML not available in runner image.

---

## Related evidence

- Run digest: `/app/data/runs/swarm_observer-1780741487896.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Gap actions (stale): `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (2026-05-31)
