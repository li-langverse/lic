# Orchestrator note — `orch-r16-ux-gap-orchestration`

**Date:** 2026-06-08  
**Agent:** `swarm_observer` (worker `c39b9d60`)  
**Research goal:** `swarm_coverage`  
**Dimension:** `ux`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **D**, 60.9; `unattended_safe: false`) |
| UX lens focus | Operator observability + studio-ui gap reconciliation |
| `orch-r4-ui-ux-signals` | **Superseded** by this note — stale snapshot drove false-open UX plan_debt rows |
| Gap ingest | **Syntax fixed** (`swarm-gap-ingest.py:229`); apply still blocked (PyYAML) |
| Unattended? | **No** — GH rate limits, 16 failing PRs, gap apply pipeline incomplete |

---

## UX gap reconciliation

### Stale registry vs live studio-ui-ux state

`studio-ui-ux` loop state (`lic/data/studio-ui-ux-plan-loop/state.json`) shows **completed**:

- `studio-ux-16-palette-search-latency`
- `studio-ux-17-gpu-fail-recovery`
- `studio-ux-21-wgpu-swapchain-gpu-runner`
- `studio-ux-24-gpu-runner-deps`

Registry rows remain **open** because `goal-directed-agents/snapshot.json` is stale (`2026-05-30`). **Action:** refresh snapshot on next `plan_verifier` tick; close matching `gap-plan-pending-studio-ui-ux-*` rows after ingest.

### Operator UX (control plane)

| Symptom | UX impact | Evidence |
|---------|-----------|----------|
| `runs_sampled=0` | Dashboard shows no swarm history | `ecosystem-quality-report.json` inputs |
| Missing `state.json` / `latest-report.json` | Observer retries look like “silent success” | `/app/data/control-plane/` (bootstrapped this pass) |
| 637 redundant PR pairs | Merge queue noise for humans | `agent-briefing.merge_plan.summary` |
| Gap apply invisible | No “patches applied” panel | `swarm-gap-actions.json` stale since 2026-05-31 |

**Handoffs:**

| Target | Work |
|--------|------|
| `gui_ux_tester` | `ui_ux_quality` goal — regression on palette + GPU recovery benches |
| `plan_verifier` | Refresh goal-directed snapshot; close stale studio-ui + orch-r4 rows |
| `gap_explorer` | Reconcile `verticals.toml` on benchmarks main after ingest green |
| `issue_planner` | PyYAML + `LI_CURSOR_AGENTS_ROOT=/app` on org-research image |

---

## Gap taxonomy (UX-relevant rows)

| `gap_kind` | Open | Primary discoverer | Orchestrator action |
|------------|-----:|------------------|---------------------|
| `plan_debt` (studio-ui) | 4 stale | `plan_verifier` | Close after snapshot refresh |
| `plan_debt` (orch-r4) | 1 | `plan_verifier` | Close when this note lands |
| `ui_ux` | 0 explicit | `gui_ux_tester` | Route via `ui_ux_quality` goal + studio plan todos |
| `competitor_feature` | 30 | `gap_explorer` | Research lane — not UX-critical this cycle |

**Do not** recommend `install-goal-plan-loop-systemd.sh` for studio-ui — async swarm + `gui_ux_tester` per `swarm-architecture.md`.

---

## Programmatic prep status

| Script | Status |
|--------|--------|
| `lic/scripts/swarm-gap-ingest.py` | **Fixed** (line 229 Path fallback) — re-run pending PyYAML for registry write |
| `lic/scripts/swarm-gap-apply-actions.py` | **Blocked** — `PyYAML required` |
| `benchmarks/scripts/ecosystem-quality-grade.py` | **Ran** — wrote scorecard 60.9 / D |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/studio-ui-ux-plan-loop/state.json`
- `/app/data/control-plane/latest-report.json`
- `/app/data/runs/swarm_observer-1780907053286.md`
