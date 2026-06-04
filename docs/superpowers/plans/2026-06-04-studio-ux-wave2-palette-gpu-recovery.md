---
name: Studio UX wave 2 — palette latency + GPU fail recovery
overview: Close master-plan-gap for studio-ux-16/17 — command palette fuzzy search with measured latency (UX-04) and GPU device-loss recovery strip (UX-08). Resume studio-ui-ux plan loop supervisor; close swarm registry plan_debt rows.
issue: li-langverse/lic#575
parent_plan: docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md
todos:
  - id: wave2-ux16-palette-composables
    content: "li-ui — StudioCommandPaletteCompose + fuzzy filter + open/filter latency hooks (UX-04)"
    status: done
  - id: wave2-ux16-palette-bench
    content: "packages/li-ui/bench/palette_latency.toml — palette_open_ms ≤50, palette_filter_ms ≤30"
    status: done
  - id: wave2-ux16-studio-shell
    content: "li-studio — palette overlay compose/paint + smokes studio_palette_search.li"
    status: done
  - id: wave2-ux17-gpu-fail-composables
    content: "li-ui/li-studio — StudioGpuFailCompose strip + retry affordance (UX-08)"
    status: done
  - id: wave2-ux17-gpu-fail-bench
    content: "packages/li-studio/bench/gpu_fail_recovery.toml — gpu_fail_retry_ms ≤100"
    status: done
  - id: wave2-ux17-li-gpu-hook
    content: "li-gpu — gpu_wgpu_smoke_fail_run() for fail-state bench hooks"
    status: done
  - id: wave2-gates-verify
    content: "studio-ui-ux-plan-gates.sh green — verify-palette-native + capture harness"
    status: done
  - id: wave2-registry-close
    content: "Close gap-plan-pending-studio-ui-ux-studio-ux-16/17 registry rows after snapshot refresh"
    status: pending
  - id: wave2-supervisor-resume
    content: "Resume studio-ui-ux plan loop supervisor for studio-ux-25 (wave 5 proactive sweep)"
    status: pending
isProject: false
---

# Studio UX wave 2 — palette latency + GPU fail recovery

**Issue:** [#575](https://github.com/li-langverse/lic/issues/575)  
**Agent:** `studio_ui_ux_builder` (implementation) · `issue_planner` (this plan)  
**Branch:** `cursor/studio-ui-ux-plan-loop`  
**Tracking issue:** `STUDIO_UI_UX_TRACKING_ISSUE` (#182)

## north_star_fit

| Pillar | Fit |
|--------|-----|
| **Proof** | Composables compile under `lic build`; smokes are `compile_ok` — no `Any`/`unsafe` shortcuts on sim path |
| **Easy** | UX-04 command palette (Linear/VS Code SOTA) + UX-08 GPU fail recovery (Primer/Cursor SOTA) |
| **Fast** | Latency budgets enforced in bench TOML before perf tuning elsewhere |

**PH ids:** PH-UX (studio slice) · UX-04 · UX-08  
**Domain:** gaming / scientific studio · li-gui / world-studio-demo

## Context

Wave 1 (studio-ux-00…15) completed 2026-05-30. Goal-directed snapshot at **2026-05-30T20:30Z** showed supervisor **stopped** with ux-16/17 `plan_pending` — filed as master-plan-gap before loop state caught up.

**Current state (main, 2026-06-04):**

- Loop `state.json` marks **studio-ux-16** and **studio-ux-17** completed (gates + capture verified).
- Implementation artifacts on main: `palette_latency.toml`, `gpu_fail_recovery.toml`, iteration reports under `docs/reports/studio-ui-ux/iterations/`.
- Swarm registry rows `gap-plan-pending-studio-ui-ux-studio-ux-16-*` and `-17-*` remain **open** (stale ingest).
- Open PRs [#722](https://github.com/li-langverse/lic/pull/722) / [#723](https://github.com/li-langverse/lic/pull/723) are agent replay branches — mostly bench snapshot deltas; **close as superseded** after human review.

This plan formalizes wave-2 scope and defines **closure WPs** for registry + supervisor.

## Learned from

1. **Linear command palette** — fuzzy search, sub-50ms open, keyboard-first discoverability ([Linear docs](https://linear.app/docs)).
2. **VS Code command palette** — filter-as-you-type latency budget; score by recency + fuzzy match ([VS Code UX](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette)).
3. **GitHub Primer** — inline error recovery with actionable retry, no raw stack in product chrome ([Primer design guidelines](https://primer.style/design/ui-patterns/error-messages)).
4. **Cursor agent UX** — device/GPU failure strip with dismiss + retry without blocking shell ([Cursor product patterns](https://cursor.com)).

## Work packages

### WP-1 — studio-ux-16: Command palette fuzzy search + latency (UX-04)

**Packages:** `li-ui`, `li-studio`

| Deliverable | Path | Status |
|-------------|------|--------|
| Fuzzy match + filter count | `li-ui` composables | done |
| Palette overlay compose/paint | `li-studio` shell | done |
| Latency bench hook | `packages/li-ui/bench/palette_latency.toml` | done |
| Smokes | `studio_palette_search.li`, `studio_palette.li` | done |
| HTML mock journey | `deploy/studio-demo/screenshots/04-studio-command-palette.html` | done |
| Gate verifier | `scripts/studio-ui-ux-verify-palette-native.py` | done |

**PH-UX gates:**

| Gate | Budget | Measured (main) |
|------|--------|-----------------|
| `palette_open_ms` | ≤ 50 ms | 14 ms |
| `palette_filter_ms` | ≤ 30 ms | 9.5 ms |

**REQ-UX-04-1:** Palette opens on ⌘K / Ctrl+K with fuzzy filter refresh on each keystroke.  
**REQ-UX-04-2:** Bench JSON fields `palette_open_ms`, `palette_filter_ms` in `data/studio-ui-ux-plan-loop/latest-bench.json`.

### WP-2 — studio-ux-17: GPU fail strip + retry (UX-08)

**Packages:** `li-ui`, `li-studio`, `li-gpu`

| Deliverable | Path | Status |
|-------------|------|--------|
| GPU fail composable + paint | `li-ui` `StudioGpuFailCompose` | done |
| Shell wiring | `li-studio` overlay | done |
| Fail-state bench hook | `packages/li-studio/bench/gpu_fail_recovery.toml` | done |
| wgpu fail smoke | `li-gpu` `gpu_wgpu_smoke_fail_run()` | done |
| Smokes | `studio_gpu_fail_recovery.li` | done |
| HTML mock journey | `deploy/studio-demo/screenshots/04-studio-gpu-fail.html` | done |

**PH-UX gates:**

| Gate | Budget | Measured (main) |
|------|--------|-----------------|
| `gpu_fail_retry_ms` | ≤ 100 ms | 15 ms |

**Honesty note:** `gpu_fail_recovery.toml` reports `native_pixels = false` (simulate path). Native GPU device-loss overlay on wgpu swapchain is tracked separately via world-studio **WP-UX-08** (`wsm-w2-viewport-error`) and studio-ux-19/21 swapchain CI — do **not** weaken gate to green simulate-only.

**REQ-UX-08-1:** Viewport overlay strip visible on GPU fail with one-click retry.  
**REQ-UX-08-2:** Retry latency instrumented; no raw driver stack in studio chrome.

### WP-3 — Gates, capture, and bench registry

Run before marking issue closed:

```bash
./scripts/studio-ui-ux-plan-gates.sh
./scripts/studio-ui-ux-capture-progress.sh   # uploads to #182 / release studio-ui-ux-progress
./scripts/bench-studio-viewport-perf.sh
```

**Bench registry:** `benchmarks/competitive/studio-ui.toml` → `data/studio-ui-ux-plan-loop/latest-bench.json`.

**Tests:**

| Package | Smoke |
|---------|-------|
| `li-ui` | `studio_palette_search.li`, `studio_palette_native.li`, `studio_gpu_fail_recovery.li` |
| `li-studio` | `studio_command_palette.li`, `studio_gpu_fail_recovery.li`, `studio_palette_native.li` |

**ux-harness:** `world-studio-demo` journey `command_palette` + `gpu_fail_recovery` (web_gui fixture); `world-studio-native` when `LIC_ROOT` + Xvfb available.

### WP-4 — Registry + snapshot hygiene (closure)

| Action | Owner | Acceptance |
|--------|-------|------------|
| Refresh goal-directed snapshot | `swarm_observer` / `./scripts/studio-ui-ux-write-snapshot.py` | `plan_pending` empty for ux-16/17 |
| Close registry rows | `swarm_observer` ingest | `gap-plan-pending-studio-ui-ux-studio-ux-16-*` → `closed` |
| Close superseded PRs | human / `pr_merger` | #722, #723 closed as duplicate-of-main |
| Resume supervisor | human / engine cluster | `./scripts/studio-ui-ux-plan-continuous.sh` or K8s goal-directed loop |

**G-* gap updates:**

| Registry id | Action |
|-------------|--------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | close — evidence: state.json + iteration report |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | close — evidence: state.json + iteration report |
| `gap-ux-studio-wave2-plan` | close — this plan doc |

## Acceptance (issue #575)

1. ✅ Plan doc linked (this file).
2. ✅ Palette p95 latency within PH-UX budgets (open ≤50 ms, filter ≤30 ms).
3. ✅ GPU fail recovery UX shipped with retry ≤100 ms (simulate path honest; native follow-up tracked).
4. ⬜ Registry `plan_debt` rows closed after snapshot refresh.
5. ⬜ Supervisor resumed for **studio-ux-25** (next pending todo in parent plan).

## Out of scope

- httpd / tier5 HTTP (separate loop).
- Weakening `threshold_ratio_cpp` or bench honesty flags.
- `trusted.lean` changes (human-approved issues only).
- Native wgpu swapchain GPU fail overlay — deferred to studio-ux-19/21 + world-studio WP-UX-08 (already partial on main).

## Handoff

| Next agent | Trigger |
|------------|---------|
| `studio_ui_ux_builder` | After `plan-approved` — resume loop at studio-ux-25 |
| `swarm_observer` | Close registry rows + refresh snapshot |
| `gui_ux_tester` | Re-run world-studio-demo + native_gui journeys post-merge |
| `pr_merger` | Human merge of any remaining delta PRs (if not superseded) |
