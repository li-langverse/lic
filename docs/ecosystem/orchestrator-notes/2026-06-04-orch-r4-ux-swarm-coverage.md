# Orchestrator note — orch-r4 UX (swarm_coverage @ ux)

**Date:** 2026-06-04  
**Goal:** `swarm_coverage` (research lane)  
**Dimension:** `ux`  
**Worker:** `e941fc6f`  
**north_star_fit:** ecosystem, ai — proof-before-perf; agent chrome and studio gates must not bypass `lic verify`.

## Signals

| Source | Finding |
|--------|---------|
| `lic/data/goal-directed-agents/snapshot.json` | `studio-ui-ux` runner **stopped**; active todos `studio-ux-16-palette-search-latency`, `studio-ux-17-gpu-fail-recovery` |
| `benchmarks/data/latest/swarm-gap-actions.json` | UX plan_debt rows patched; **studio backlog apply skipped** — `lic-studio-ui` plan loop not mounted in org-research Job |
| `config/implement-goals.yaml` | `studio_ui_ux` → `gui_ux_tester`, backlog `docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` |
| `config/research-goals.yaml` | `ui_ux_quality` → audit handoff to `code_implementer` / `issue_planner` (no new systemd loops) |
| Briefing heap | `ci_maintainer` + `security_auditor` only — UX not heap-queued despite registry UX debt |

## Reconciliation (Mode B)

1. **Do not** install `install-goal-plan-loop-systemd.sh` for studio-ui; use agents control plane (`studio_ui_ux` implement goal + `gui_ux_tester`).
2. Mount `lic-studio-ui` in org-research Job **or** copy plan backlog path into `lic` handoff doc so `swarm-gap-apply-actions.py` can patch todos.
3. Route `studio-ux-16/17` → `gui_ux_tester` with gates from `scripts/studio-ui-ux-plan-gates.sh`; cite PH-UX / panel_switch_ms on handoffs.
4. Close stale registry rows where `completed_ids` already includes todo (snapshot drift — refresh snapshot on host after wave-4).
5. `gap_explorer` should dedupe `plan_debt` studio rows after snapshot refresh.

## Handoffs

| Agent | Work |
|-------|------|
| `gui_ux_tester` | Palette search latency (UX-04), GPU fail strip (UX-08), wgpu readback bench honesty |
| `plan_verifier` | Refresh goal-directed snapshot; align registry `plan_pending` vs `completed_ids` |
| `gap_explorer` | Post-snapshot registry ingest; competitor_feature numerics/viz stubs |
| `ci_maintainer` | `li-sec-agent` CI on main (briefing P0); benchmarks physics-codegen CI wave |

## Evidence

- Meta audit: `li-cursor-agents/data/runs/swarm_observer-1780544606162.md`
- Scorecard: `benchmarks/data/latest/ecosystem-quality-report.json` (grade D, `unattended_safe=false`)
- Registry: `lic/data/swarm-gap-registry/registry.yaml` (92 gaps after ingest @ 2026-06-04T03:52Z)
