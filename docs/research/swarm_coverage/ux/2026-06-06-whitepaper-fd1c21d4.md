# Swarm gap orchestration — UX dimension whitepaper

**Goal id:** `swarm_coverage`  
**Dimension:** `ux`  
**Agent:** `swarm_observer`  
**Worker:** `fd1c21d4`  
**Run:** `swarm_observer-1780784700908`  
**Generated:** 2026-06-06T22:53Z  
**north_star_fit:** ecosystem, ai — proof-before-perf; operator surfaces must be accessible and honest

---

## Abstract

This pass audits UX-related swarm gaps under the `swarm_coverage` research goal. The Li agent swarm is **degraded** (ecosystem grade D, 60.9) and **not unattended-safe**. The dominant UX friction is an eight-PR stack of failing benchmarks dashboard fixes for GPU chip picker ARIA tabs, compounded by eleven open studio-ui-ux plan-debt registry rows and absent control-plane health artifacts for operators.

Static documentation UX (`lic-docs`) passes automated rubric and axe audits. Interactive surfaces — benchmarks dashboard, org supervisor dashboard, world-studio GUI — lack consolidated audit coverage and swarm routing.

---

## Method

1. Refreshed `ecosystem-quality-report.json` via `ecosystem-quality-grade.py`
2. Read `agent-briefing.json`, `swarm-gap-registry/registry.yaml`, `swarm-gap-actions.json`
3. Cross-referenced `ux-audit.json` and `ui-audit.json` for static-site baseline
4. Attempted gap ingest/apply (blocked — documented errors)
5. Mapped `orch-r4-ui-ux-signals` plan todo to concrete handoffs

---

## Findings

### F1 — Benchmarks GPU chip picker PR duplication (high)

Eight open PRs (#400–409) implement the same ARIA tablist + keyboard roving fix for issue #147. All fail CI. This blocks operator progress on dashboard accessibility and inflates merge-planner redundant pairs (193 org-wide).

**Recommendation:** Single canonical PR; `gui_ux_tester` verification; close duplicates via `pr_alignment`.

### F2 — Studio UI plan-debt backlog (high)

Eleven registry rows tie to `studio-ui-ux` runner todos (particle display, agent chrome, wgpu swapchain, GPU runner deps). Runner marked stopped in snapshot @ 2026-05-30. Two todos patched to plan-loop markdown @ 2026-05-31; remainder need `gui_ux_tester` + `studio_ui_ux_builder`.

### F3 — Gap taxonomy misses `ui_ux` (medium)

No registry rows use `gap_kind: ui_ux`. Dashboard and studio friction is buried in `plan_debt`, reducing discoverability for `gui_ux_tester` heap dispatch.

### F4 — Operator control-plane UX (medium)

`/app/data/control-plane/` lacks `latest-report.json` and `state.json`. Operators cannot see swarm health, retry counts, or gap-apply status in offline dashboard mode.

### F5 — Static docs healthy (positive)

`lic-docs` passes UX rubric (nav_clarity 0.85 ≥ 0.7) and axe audit (0 violations). Baseline is sound; extend coverage to live apps.

---

## Handoff matrix

| Priority | Surface | Agent | Goal |
|----------|---------|-------|------|
| P0 | Benchmarks GPU picker | `gui_ux_tester` | `ui_ux_quality` |
| P1 | Studio UI todos | `studio_ui_ux_builder` | implement-goals |
| P1 | PR deduplication | `pr_alignment` | coord_pull_requests |
| P2 | Dashboard health UX | `gui_ux_tester` | `ui_ux_quality` |
| P2 | Gap reclass | `swarm_observer` | `swarm_coverage` |

---

## Validity

| Criterion | Grade | Notes |
|-----------|-------|-------|
| Evidence freshness | B | Briefing @ 22:53Z; gap actions stale @ 05-31 |
| Reproducibility | C | Ingest/apply blocked — read-only reconcile |
| Actionability | A | Concrete PR stack + handoff targets |
| north_star_fit | A | Accessibility + honest operator UX align with easy pillar |

**Overall validity:** B−

---

## Artifacts

| Path | Role |
|------|------|
| `/app/data/runs/swarm_observer-1780784700908.md` | Run digest |
| `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r4-ui-ux-signals-fd1c21d4.md` | orch-r4 completion |
| `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` | Scorecard |
| `/workspace/benchmarks/data/latest/ux-audit.json` | Static UX baseline |

**Publish target (deferred):** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`

---

## References

- `docs/ecosystem/research-verticals.md` — `swarm_coverage`, `ui_ux_quality` goals
- `config/research-goals.yaml` — routing source of truth
- Prior UX pass: `org-research-audit.jsonl` @ 2026-06-06T20:19Z (worker `37804ad2`)
