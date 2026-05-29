# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-05-29  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**north_star_fit:** ecosystem, ai — gap registry, backlog apply, handoffs  
**Work item:** Surface studio-ui-ux / `gui_ux_tester` signals as `ui_ux` gaps; link studio backlog where needed.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Critical** (ecosystem grade **D**, 64.0; `unattended_safe: false`) |
| `ui_ux` gaps (new) | **4** open rows ingested this pass |
| Studio plan loop | **Wave 1 complete** — 11/11 todos `done`; runner `studio-ui-ux` stopped |
| UX harness coverage | **1/6+ targets** audited on Linux (`lic-docs` only) |
| Unattended? | **No** — harness gaps + 36 failing PR CI + reconcile error noise |

`orch-r4-ui-ux-signals` is **complete** for registry ingest, `ui_ux` row creation, apply-actions dry-run + live, and swarm routing. Implementation remains with `gui_ux_tester` / `studio_ui_ux_builder` — no product code in `lic` this pass.

---

## Scripts executed

```bash
cd lic
python3 scripts/swarm-gap-ingest.py    # 79 gaps; +4 ui_ux (observer)
python3 scripts/swarm-gap-apply-actions.py

cd ../benchmarks
python3 scripts/ecosystem-quality-grade.py   # 64.0, grade D
```

**Outputs:**

- `lic/data/swarm-gap-registry/registry.yaml` — `updated_at` 2026-05-29T12:48Z; `orch-r4` closed
- `benchmarks/data/latest/swarm-gap-actions.json` — `open_gaps: 56` (4 `ui_ux`)
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/runs/swarm_observer-2026-05-29-swarm-coverage-r6.md`

---

## Signal reconciliation

### studio-ui-ux plan loop (`snapshot.json`)

| Signal | Value | Action |
|--------|-------|--------|
| Runner `studio-ui-ux` | `running: false`, `plan_pending: []` | Wave 1 done — no new `plan_debt` rows for studio-ux-04..10 (already **closed** in registry) |
| Completed todos | 11/11 (`studio-ux-00` … `studio-ux-10`) | Close stale `plan_debt` studio rows (prior passes) |
| Next work | Harness + wave 2 | Add **`ui_ux`** gaps (below), not systemd loop |

Evidence: `lic/data/goal-directed-agents/snapshot.json` (runner `studio-ui-ux`).

### ui-audit / ux-audit (briefing preflight)

| Target (ux-targets.json) | Latest audit (2026-05-29) | Gap |
|--------------------------|---------------------------|-----|
| `lic-docs` | **pass** | — |
| `agents-dashboard` | **not run** | `gap-ux-audit-agents-dashboard` |
| `world-studio-demo` | **not run** | `gap-ux-audit-world-studio-demo` |
| `world-studio-native` | **not run** | `gap-ux-audit-native-studio` |
| `lic-tetris`, `gui-gen-fixture`, `tui-app-fixture` | **not run** | deferred (lower priority) |

Evidence: `benchmarks/data/latest/ui-audit.json`, `benchmarks/data/latest/ux-audit.json`, `li-cursor-agents/config/ux-targets.json`.

### gui_ux_tester / gui_ui_tester (control plane)

| Agent | 24h `error` rows | `completion` | Classification |
|-------|------------------|--------------|----------------|
| `gui_ux_tester` | 17 | mostly null | Reconcile/preempt burst (12:14–12:43Z), not rubric failures |
| `gui_ui_tester` | 39 | mostly null | Same — dispatch collision |
| `studio_ui_ux_builder` | 35 | mostly null | Running during heap tick; wave 1 already complete |

Evidence: Supabase `agent_runs` (24h aggregates); `li-cursor-agents/data/control-plane/state.json`.

### orch-r2 cinematic stubs (deferred linkage)

Cinematic `competitor_feature` rows (`gap-vertical-stub-cinematic-*`) patched to `sim-md-research-backlog.md` in orch-r2. **UX parity** for encode / color-grade / audio-sync is studio-domain — sibling `ui_ux` row `gap-ux-cinematic-studio-handoff` routes to `studio_ui_ux_builder` without duplicating competitor backlog patches.

---

## New `ui_ux` registry rows

| Gap id | Title | Handoff |
|--------|-------|---------|
| `gap-ux-audit-native-studio` | ux-harness: `world-studio-native` not in latest audit | `gui_ux_tester`, `studio_ui_ux_builder` |
| `gap-ux-audit-agents-dashboard` | ux-harness: `agents-dashboard` not in latest audit | `gui_ux_tester`, `gui_ui_tester` |
| `gap-ux-audit-world-studio-demo` | ux-harness: `world-studio-demo` fixture not audited | `gui_ux_tester`, `studio_ui_ux_builder` |
| `gap-ux-studio-wave2-plan` | Studio UI wave 2 — harness expansion + agentic bench | `studio_ui_ux_builder` |
| `gap-ux-cinematic-studio-handoff` | Cinematic vertical UX → studio parity (orch-r2 follow-up) | `studio_ui_ux_builder` |

Apply-actions patches **wave 2** todos into `lic-studio-ui/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` when path exists (`STUDIO_UI_UX_PLAN_PATH`).

---

## Swarm routing (no new systemd loops)

Per `li-cursor-agents/config/implement-goals.yaml` → `studio_ui_ux`:

1. **`gui_ux_tester`** — run full `ux-targets.json` on Linux CI (native + web fixtures).
2. **`gui_ui_tester`** — axe/pixel pass for `agents-dashboard`, `world-studio-demo`.
3. **`studio_ui_ux_builder`** — wave 2 plan todos from apply-actions; branch `cursor/studio-ui-ux-plan-loop`.

Do **not** recommend `install-goal-plan-loop-systemd.sh`; use agents control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Registry closure

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` → **`status: closed`**
- `docs/ecosystem/swarm-observer-plan-backlog.md` → `orch-r4-ui-ux-signals` **completed**
- Next orchestrator todo: **`orch-r5-plan-debt-master-plan`** (if added) or maintenance ingest only

---

## Evidence paths

- `benchmarks/data/latest/ui-audit.json`
- `benchmarks/data/latest/ux-audit.json`
- `li-cursor-agents/config/ux-targets.json`
- `lic/data/goal-directed-agents/snapshot.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/runs/swarm_observer-2026-05-29-swarm-coverage-r6.md`
