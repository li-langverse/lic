# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-05-31  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Work item:** Link UI/UX gap signals to studio plan loop todos; reconcile `gui_ui_tester` / `gui_ux_tester` failures

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **B** (82.0); SDK wave-kill @ 00:50Z dominates today's error count |
| `orch-r4` | **Completed (orchestration)** — `studio-ux-16` / `studio-ux-17` patched pending in studio-ui plan loop |
| UI agent failures | `gui_ui_tester` SDK zero-tool errors — harness never ran; separate from SDL capture regression |
| Unattended? | **Marginal** — UX work routed to plan todos; native capture fix still needs `li-cursor-agents` PR |

Gap apply confirmed @ 2026-05-31T00:54Z:

- `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` → pending in `2026-05-24-studio-ui-ux-plan-loop.md`
- `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` → pending in same plan file

Registry row `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` remains open until next ingest records completion.

---

## UI/UX gap reconciliation

| Registry id | Plan todo | Patch target | Handoff |
|-------------|-----------|--------------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `studio-ux-16` | `2026-05-24-studio-ui-ux-plan-loop.md` | `studio_ui_ux_builder`, `gui_ux_tester` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `studio-ux-17` | same | `studio_ui_ux_builder`, `gui_ui_tester` |

Evidence:

- `benchmarks/data/latest/swarm-gap-actions.json` (patches @ 00:54Z)
- `lic/data/goal-directed-agents/snapshot.json` → runner `studio-ui-ux` **stopped** (plan loop idle)
- `li-cursor-agents/data/runs/gui_ui_tester-1780188668577.json` — SDK error, no capture output

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `studio_ui_ux_builder` | Implement studio-ux-16/17 when plan loop resumes via agents control plane |
| `gui_ux_tester` | Design review + axe after builder lands palette/GPU recovery |
| `gui_ui_tester` | Re-run after SDK wave-kill stabilization + SDL capture fix |

Do **not** recommend `install-goal-plan-loop-systemd.sh` for studio-ui — migrated to agents control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Control-plane fixes (orchestration)

1. **`finalize-run.ts`** — zero-tool SDK errors after supervisor restart → `incomplete`, not `error`.
2. **`ux-harness/`** — SDL `RenderReadPixels` 0 frames (prior pass: `gui_ui_tester-1780177405633.json`).
3. **Research lane** — dedupe concurrent `swarm_observer` workers during `swarm_coverage` cadence.

---

## Human-only

- Studio UX product changes in `lic` / `studio` repos — human review on PR.
- Native GPU fail-recovery behavior — game-dev UX policy.

---

## Evidence paths

- `benchmarks/data/runs/swarm_observer-1780189200.md`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `li-cursor-agents/config/research-goals.yaml` → `swarm_coverage`
