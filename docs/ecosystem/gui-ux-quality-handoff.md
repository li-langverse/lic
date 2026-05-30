# GUI UX quality — agent handoff (`ui_ux_quality`)

**Research goal:** `ui_ux_quality` · **Primary agent:** `gui_ux_tester` (`li-cursor-agents`)  
**Handoff agents:** `studio_ui_ux_builder`, `gui_ui_tester`, `docs_maintainer`, `issue_planner`  
**north_star_fit:** easy · ai-first — honest Studio/agent surfaces for swarm diagnostics (**Vision-LLM**)

This page is the **lic-side routing doc** for UX journeys on GUI targets. Product fixes stay in `li-cursor-agents` / `lic-studio-ui`; **do not** weaken Lean or proof gates in `lic` when closing UX gaps.

---

## Canonical artifacts

| Artifact | Repository | Path |
|----------|------------|------|
| UX target registry | `li-cursor-agents` | [`config/ux-targets.json`](https://github.com/li-langverse/li-cursor-agents/blob/main/config/ux-targets.json) |
| UX harness | `li-cursor-agents` | [`ux-harness/`](https://github.com/li-langverse/li-cursor-agents/tree/main/ux-harness) |
| Latest UX audit (preflight) | `benchmarks` | `data/latest/ux-audit.json` — today often **docs-only** (`lic-docs`) |
| Latest UI audit (GUI) | `benchmarks` | `data/latest/ui-audit.json` or proactive `data/latest-gui-ui-run/ui-audit.json` |
| UX digests | `benchmarks` | [`docs/ecosystem/ux-digests/`](https://github.com/li-langverse/benchmarks/tree/main/docs/ecosystem/ux-digests) |
| Studio UX rubric | `lic` | [ui-ux-by-dimension.md](../game-dev/competitive-intel/ui-ux-by-dimension.md) |
| Studio plan loop | `lic` | [2026-05-24-studio-ui-ux-plan-loop.md](../superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md) |
| Swarm registry ingest | `lic` | [orch-r4-ui-ux-signals](orchestrator-notes/2026-05-29-orch-r4-ui-ux-signals.md) |

---

## GUI targets (journeys `gui_ux_tester` must exercise)

From `ux-targets.json` — **surface_class** `gui_app` / `gui_gen`:

| Target id | Repo | Adapter | Journeys (summary) | Honesty note |
|-----------|------|---------|-------------------|--------------|
| `agents-dashboard` | `li-cursor-agents` | `web_gui` | empty state, live stream | Requires dev server; port alignment ([#38](https://github.com/li-langverse/li-cursor-agents/issues/38)) |
| `world-studio-demo` | `lic` | `web_gui` (fixture) | viewport, palette, keyboard | HTML mock — not full `li-studio` binary; **studio-ux-12** Linux harness audit wired (Partial — still mock) |
| `world-studio-native` | `lic` | `native_gui` | Xvfb SDL PNG capture | Needs `LIC_ROOT` + `scripts/studio-ui-ux-capture-native.sh` ([#394](https://github.com/li-langverse/lic/issues/394)) |
| `lic-tetris` | `lic` | `native_gui` | play session | Must not reuse studio stub ([#46](https://github.com/li-langverse/li-cursor-agents/issues/46), [#515](https://github.com/li-langverse/lic/issues/515)) |
| `gui-gen-fixture` | `li-cursor-agents` | `web_gui` | gen preview loop | `http_probe` only until Playwright ([#32](https://github.com/li-langverse/li-cursor-agents/issues/32)) |

**Rubric:** score UX-01…UX-14 (0–3) per [ui-ux-by-dimension.md](../game-dev/competitive-intel/ui-ux-by-dimension.md). Label **Partial** when mock/native distinction matters (**UX-12**, **UX-13**, **UX-14**).

---

## Open `ui_ux` swarm gaps (registry)

Ingested by `swarm_observer` (`orch-r4-ui-ux-signals`); see [orchestrator note](orchestrator-notes/2026-05-29-orch-r4-ui-ux-signals.md):

| Gap id | Owner agents |
|--------|----------------|
| `gap-ux-audit-native-studio` | `gui_ux_tester`, `studio_ui_ux_builder` |
| `gap-ux-audit-agents-dashboard` | `gui_ux_tester`, `gui_ui_tester` |
| `gap-ux-audit-world-studio-demo` | `gui_ux_tester`, `studio_ui_ux_builder` — **Partial:** studio-ux-12 harness on Linux; fixture still HTML mock |
| `gap-ux-studio-wave2-plan` | `studio_ui_ux_builder` |
| `gap-ux-cinematic-studio-handoff` | `studio_ui_ux_builder` |

Wave 1 studio plan todos are **done**; wave 2 is harness expansion + agentic bench — not a new systemd loop.

---

## Workflow repo routing

| Agent | Primary clone | Notes |
|-------|---------------|-------|
| `gui_ux_tester` | `li-cursor-agents` (harness) + `lic-studio-ui` worktree for native capture | Set `LIC_ROOT` to `lic-studio-ui` for SDL targets ([#47](https://github.com/li-langverse/li-cursor-agents/issues/47)) |
| `studio_ui_ux_builder` | `lic` branch `cursor/studio-ui-ux-plan-loop` | Plan loop gates + capture scripts |
| `docs_maintainer` | `lic` (this handoff) + `benchmarks` (digests) | No product code |

Latest companion digests: [2026-05-30-gui-ui.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/ux-digests/2026-05-30-gui-ui.md) (`gui_ui_tester`), [studio-ui-ux-builder-digest](https://github.com/li-langverse/benchmarks/blob/main/data/latest/studio-ui-ux-builder-digest.md).

---

## Runbook (`gui_ux_tester`)

1. Read briefing `ux-audit.json` / `ui-audit.json` (or run proactive harness → `benchmarks/data/latest-gui-ui-run/`).
2. For each **failing** GUI target, file issues via **ui-ux-remediation** template (`li-cursor-agents`).
3. Write digest `benchmarks/docs/ecosystem/ux-digests/YYYY-MM-DD-gui-ux.md` (link issues; no product code in tester run).
4. Append P0/P1 to `implementation_queue` when enrich is enabled.

**Do not:** mark proof **G-*** rows **Done** from UX pass/fail; perf claims require [benchmarks dashboard](https://li-langverse.github.io/benchmarks/) + `catalog.toml` row.

---

## Related plan map

[Plan cross-links](plan-cross-links.md) · [Master plan — Documentation & provability honesty](../superpowers/plans/2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting)
