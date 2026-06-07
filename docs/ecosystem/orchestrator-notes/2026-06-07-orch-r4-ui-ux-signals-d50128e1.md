# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `d50128e1`  
**Research goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Work item:** Surface studio-ui-ux / `gui_ux_tester` signals as `ui_ux` gaps; link studio backlog + swarm dashboard UX

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **D**, 63.9; `unattended_safe: false`) |
| `orch-r4` | **In progress** — UX signals catalogued; registry ingest **blocked** (ingest SyntaxError + PyYAML) |
| `ui_ux` gap rows in registry | **0** (taxonomy referenced in handoff doc but not yet ingested) |
| Studio plan debt (UX) | **4 open** todos patched to plan loop file |
| Unattended? | **No** — gap pipeline + control-plane persistence gaps |

---

## UX signals reconciled (this pass)

### Studio plan loop (`2026-05-24-studio-ui-ux-plan-loop.md`)

| Todo id | Status | UX dimension | Bench artifact |
|---------|--------|--------------|----------------|
| `studio-ux-16-palette-search-latency` | pending | UX-04 Cmd+K | `packages/li-ui/bench/palette_latency.toml` |
| `studio-ux-17-gpu-fail-recovery` | pending | UX-08 GPU fail | `packages/li-studio/bench/gpu_fail_recovery.toml` |
| `studio-ux-21-wgpu-swapchain-gpu-runner` | pending (patched) | UX-12/13 native | plan loop |
| `studio-ux-24-gpu-runner-deps` | pending (patched) | UX-13 deps | plan loop |

**Apply artifact:** `swarm-gap-actions.json` already patched `studio-ux-21/24` → plan loop (2026-05-31).  
**Gap apply live run:** skipped — `lic-studio-ui` plan path not mounted; PyYAML missing.

### `gui_ux_tester` proactive audit (reference)

Source: `lic/docs/ecosystem/gui-ux-quality-handoff.md`

| Target | Status | UX blocker |
|--------|--------|------------|
| `agents-dashboard` | **skip** | Dev server not at `:3000` — swarm health UX invisible to harness |
| `world-studio-demo` | pass (Partial) | HTML mock, not full `li-studio` |
| `world-studio-native` | pass | Needs `LIC_ROOT=lic-studio-ui` |
| `gui-gen-fixture` | pass | `http_probe` only — no axe/pixel |

### Swarm control-plane UX gap

| Signal | User impact |
|--------|-------------|
| `state.json` / `latest-report.json` absent | Dashboard cannot show retry budget, `swarm_degraded`, or intervention history |
| `runs_sampled=0` in scorecard | Ecosystem grade understates execution health |
| 64 frozen gap rows | Gap-apply panel shows stale backlog |

---

## Proposed `ui_ux` registry rows (pending ingest)

When `swarm-gap-ingest.py` is fixed and PyYAML available, add:

```yaml
- id: gap-ux-audit-agents-dashboard
  gap_kind: ui_ux
  title: "agents-dashboard: empty state + live stream UX (port alignment)"
  status: open
  priority: 7
  discovered_by: gui_ux_tester
  evidence:
    - ux-targets.json journey skip 2026-05-30
    - li-cursor-agents#38
  handoff_to: [gui_ux_tester, code_implementer]

- id: gap-ux-studio-palette-latency
  gap_kind: ui_ux
  title: "Studio Cmd+K palette fuzzy search latency SLO (studio-ux-16)"
  status: open
  priority: 6
  discovered_by: swarm_observer
  evidence:
    - studio-ux-16-palette-search-latency pending
    - packages/li-ui/bench/palette_latency.toml
  target_backlog: docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md
  target_todo_id: studio-ux-16-palette-search-latency
  handoff_to: [studio_ui_ux_builder, gui_ux_tester]

- id: gap-ux-studio-gpu-recovery
  gap_kind: ui_ux
  title: "Studio GPU fail strip + retry affordance (studio-ux-17)"
  status: open
  priority: 6
  discovered_by: swarm_observer
  evidence:
    - studio-ux-17-gpu-fail-recovery pending
    - packages/li-studio/bench/gpu_fail_recovery.toml
  target_backlog: docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md
  target_todo_id: studio-ux-17-gpu-fail-recovery
  handoff_to: [studio_ui_ux_builder, gui_ux_tester]

- id: gap-ux-swarm-health-panel
  gap_kind: ui_ux
  title: "Org supervisor dashboard: swarm health + gap-apply status panel"
  status: open
  priority: 8
  discovered_by: swarm_observer
  evidence:
    - ENOENT data/control-plane/state.json
    - ecosystem-quality-report runs_sampled=0
  handoff_to: [code_implementer, gui_ux_tester]
```

---

## Routing (no new systemd loops)

| Work | Route via |
|------|-----------|
| Studio UX todos | `studio_ui_ux_builder` on `cursor/studio-ui-ux-plan-loop` |
| GUI audit sweep | `gui_ux_tester` goal `ui_ux_quality` (`cadence_hours: 48`, priority 5) |
| Dashboard swarm panel | `code_implementer` in `li-cursor-agents` |
| Gap registry update | `gap_explorer` after ingest fix |

**Research goals** (`li-cursor-agents/config/research-goals.yaml`):

- `swarm_coverage` → `swarm_observer` (this note)
- `ui_ux_quality` → `gui_ux_tester` (handoff after orch-r4 ingest)

---

## Scripts executed

```bash
# benchmarks (refreshed scorecard)
python3 scripts/ecosystem-quality-grade.py
# → overall_score=63.9 grade=D unattended_safe=False

# lic (blocked)
python3 scripts/swarm-gap-ingest.py      # SyntaxError line 229
python3 scripts/swarm-gap-apply-actions.py  # PyYAML required
```

---

## Evidence paths

| Artifact | Path |
|----------|------|
| Swarm observer digest | `/app/data/runs/swarm_observer-1780835617633.md` |
| Ecosystem scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Studio plan loop | `/workspace/lic/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` |
| UX handoff | `/workspace/lic/docs/ecosystem/gui-ux-quality-handoff.md` |
| Whitepaper staging | `/workspace/lic/docs/research/swarm_coverage/ux/2026-06-07-whitepaper-d50128e1.md` |

---

## Next steps

1. Merge lic PR fixing `swarm-gap-ingest.py:229` (existing PRs #991–#1025 family).
2. Bake `python3-yaml` in org-research worker image.
3. Re-run ingest + apply; close `orch-r4-ui-ux-signals` in `swarm-observer-plan-backlog.md`.
4. Dispatch `gui_ux_tester` for full five-target sweep once `agents-dashboard` port fixed.
5. Persist control-plane state so dashboard UX can show live swarm health.

**Do not** install `install-goal-plan-loop-systemd.sh` — retired per `docs/ecosystem/swarm-architecture.md`.
