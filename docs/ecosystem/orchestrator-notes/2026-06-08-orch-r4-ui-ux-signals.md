# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-08  
**Agent:** `swarm_observer` (worker `da775a5b`)  
**Research goal:** `swarm_coverage` — dimension **ux**  
**north_star_fit:** ecosystem, ai — swarm gap orchestration UX lens  
**Work item:** Link `ui_ux` gap signals → `gui_ux_tester` / `ui_ux_quality` handoffs; reconcile studio-ui registry drift

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (65.3); `unattended_safe: false` |
| `orch-r4` | **Completed (orchestration)** — UX signal map + stale-row reconcile plan |
| Registry UX debt | 2 `studio-ui-ux` plan_debt rows open in registry but **done** in plan loop |
| Gap ingest | **Blocked** — `swarm-gap-ingest.py` syntax fixed; **PyYAML missing** in runtime |
| Handoff target | `gui_ux_tester` via `ui_ux_quality` goal (cadence 48h, priority 5) |

Evidence: `benchmarks/data/latest/ecosystem-quality-report.json`, `lic/data/swarm-gap-registry/registry.yaml`, `lic/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md`.

---

## UX gap taxonomy reconciliation

| `gap_kind` | Open UX rows | Discoverer | Orchestrator action |
|------------|--------------|------------|---------------------|
| `ui_ux` | 0 explicit | `gui_ux_tester` | Route via `ui_ux_quality` goal — no new registry ids |
| `plan_debt` (studio-ui) | 2 stale | `plan_verifier` | Close after snapshot refresh (see below) |
| `competitor_feature` (viz stubs) | `scientific_viz`, cinematic_* | `gap_explorer` | Handoff `numerics_researcher` / `game_engine_ux` research — not product code here |

### Stale registry rows (snapshot drift)

| Registry id | Plan loop status | Evidence | Action |
|-------------|------------------|----------|--------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | **done** (`studio-ux-16`) | `docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md`; iteration `20260530T092400Z-studio-ux-16-palette-search-latency.md` | **Close** on next ingest after `goal-directed-agents/snapshot.json` refresh |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | **done** (`studio-ux-17`) | plan loop + `20260530T120800Z-studio-ux-17-gpu-fail-recovery.md` | **Close** on next ingest |

Root cause: `lic/data/goal-directed-agents/snapshot.json` generated **2026-05-30** — predates studio-ux-16/17 completion.

---

## UX signal → swarm handoff map

| Signal | Bench / artifact | Severity | Handoff |
|--------|------------------|----------|---------|
| Palette open/filter latency (UX-04) | `packages/li-ui/bench/palette_latency.toml` | medium | `gui_ux_tester` → `ui_ux_quality` |
| GPU fail strip + retry (UX-08) | `packages/li-studio/bench/gpu_fail_recovery.toml` | medium | `gui_ux_tester` → `code_implementer` if regression |
| Swarm dashboard run history empty | `data/control-plane/` missing mirrors | high | `swarm_observer` control-plane fix |
| Agent briefing UX (preflight skips) | 8 scripts `--skip-slow` | medium | `plan_verifier` enable `plan_audit` |

No new agent registry ids. Use existing `config/research-goals.yaml` row:

```yaml
- id: ui_ux_quality
  agent: gui_ux_tester
  handoff_to: [code_implementer, docs_maintainer, issue_planner]
```

---

## Programmatic prep status

| Step | Status | Detail |
|------|--------|--------|
| `swarm-gap-ingest.py` | **partial** | Fixed `ingest_verticals_stubs` Path fallback (line 226–240); blocked on PyYAML |
| `swarm-gap-apply-actions.py` | **not run** | Depends on ingest + PyYAML |
| `ecosystem-quality-grade.py` | **ok** | Regenerated 2026-06-08T04:03:04Z → 65.3 / D |

---

## Recommended next actions (orchestration only)

1. **`plan_verifier`** — refresh `goal-directed-agents/snapshot.json`; re-run ingest to close studio-ux-16/17 registry rows.
2. **`gui_ux_tester`** — next `ui_ux_quality` cadence: regression pass on palette + GPU recovery benches.
3. **`li-cursor-agents` deploy** — add `python3-yaml` (or `PyYAML`) to org-research image; mount `LIC_ROOT` + `BENCHMARKS_ROOT`.
4. **Human:** merge **lic#1222** (`gap-ingest Path fallback`) — complements local syntax fix.

---

## `orch-r4` completion

- UX signal map documented with evidence paths.
- Stale studio-ui registry rows identified; closure gated on snapshot refresh (not manual product edits).
- Handoffs routed via `ui_ux_quality` → `gui_ux_tester` per `docs/ecosystem/research-verticals.md`.

**Do not** recommend `install-goal-plan-loop-systemd.sh` — studio-ui work migrates through agents control plane (`docs/ecosystem/swarm-architecture.md`).
