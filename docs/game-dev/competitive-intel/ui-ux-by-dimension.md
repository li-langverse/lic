# UI/UX competitive intel — 14 dimensions

**Status:** Active (2026-05-23)  
**Li target:** [world-studio-vision.md](../world-studio-vision.md) PH-UX (≥60 fps viewport, &lt;100 ms panel switch, ≤3 clicks AM export, WCAG 2.2 AA)  
**Implementation today:** `packages/li-ui` composables + `adaptive_layout_hd()` + `studio_chrome_*` + `workspace_chrome_hd()` / `DockPanel`; `packages/li-gui` studio shell + `DockTab`; `packages/li-studio` wires `import gui` + dock chrome (`studio_wire_gui_hd`)

Agents: when changing Studio shell, cite dimension IDs in PR body (`UX-02: …`). Steal **patterns**, not pixels — Li uses `studio.design` tokens (RFC stub).

---

## Dimension index

| ID | Dimension | Primary incumbents | Li package / API |
|----|-----------|-------------------|------------------|
| UX-01 | Viewport & 3D navigation | Blender, UE, Unity | `render`, wgpu |
| UX-02 | Panel layout & docking | Blender N-panel, UE dock tabs | `ui`, `gui`, `studio.adaptive` |
| UX-03 | Command palette & shortcuts | Blender search, VS Code | `li-studio` (planned) |
| UX-04 | Properties / inspector | ParaView Properties | `gui`, `ui` + sim inspectors |
| UX-05 | Timeline & playback | UE Sequencer, Blender Dope Sheet | `seq` (stub) |
| UX-06 | Scientific visualization | ParaView, VTK, MATLAB | `sim.viz` |
| UX-07 | Drug-discovery stages | Roche LITL, Recursion LOWE | `studio.adaptive`, `sim.drug_design` |
| UX-08 | AM / slicer workflow | PrusaSlicer, Cura | `sim.additive` |
| UX-09 | Export & handoff | Prusa SD export, 3MF | `studio.publish` |
| UX-10 | Profile switching | UE project settings, CARLA configs | `sim_*` profiles |
| UX-11 | Agent / MCP surfaces | Copilot panels, LOWE chat | PH-AGENT, `lic build` gate |
| UX-12 | Accessibility | WCAG 2.2 AA (chrome) | `studio.design` |
| UX-13 | Performance perception | Game UI latency budgets | PH-UX metrics |
| UX-14 | Onboarding & templates | UE templates, Blender defaults | `world_scaffold` MCP |

---

## UX-01 — Viewport & 3D navigation

**Incumbents:** Blender 3D View (`VIEW_3D` + region `UI`), Unreal editor viewports, Unity Scene view.

**Patterns to steal**

- Persistent viewport + optional quad split (ParaView `SplitView`; UE community Blender-like splits)
- Mode-specific navigation (orbit / pan / zoom) with visible toolbar hints
- Gizmo overlay for transform tools (Blender tool shelf)

**Li gap:** No wgpu viewport in `li-ui` yet — types only (`UiFrame`, `InputState`).  
**Next:** `render` smoke + input → `ui_frame_begin` wiring.

**Offline:** `downloads/blender-panel-api.html`

---

## UX-02 — Panel layout & docking

**Incumbents:** Blender `Panel` + `bl_parent_id` sub-panels; PrusaSlicer right sidebar profiles.

**Patterns to steal**

- Collapsible sections (`DEFAULT_CLOSED` for advanced settings)
- Parent/child panel hierarchy for stage-specific detail
- Fixed chrome ratios: sidebar ~22%, main ~56%, inspector ~22% (see `adaptive_layout_hd()` in `li-ui`)

**Li today:** `AdaptiveLayout`, `adaptive_panel_rect_ml()`, role helpers (`layout_role_*`); `WorkspaceChrome`, `DockPanel`, `dock_zone_*` on `import ui`; `DockTab`, `studio_shell_dock_zone_rect()` on `import gui`; `studio_wire_gui_hd()` on `import studio`.  
**Next:** Parameterized viewport layout (blocked on float move semantics — use int or copy API).

**Offline:** `downloads/blender-panel-api.html`, `downloads/prusa-ui-overview.html`

---

## UX-03 — Command palette & shortcuts

**Incumbents:** Blender operator search, UE editor utility widgets.

**Patterns to steal**

- Single fuzzy-search entry for actions + recent files
- Context-sensitive command sets (viewport vs graph vs sim)

**Li gap:** Not implemented — document in `studio-ux-design-system-rfc.md` when PH-GD-1 lands.

---

## UX-04 — Properties / inspector

**Incumbents:** ParaView Properties panel (source + Display + View sections).

**Patterns to steal**

- **Default vs advanced** property modes + search box
- Optional split: Properties / Display / View in separate docks
- **Apply / Reset** for heavy pipeline edits; **instant apply** for view options (ParaView View section)
- **Auto Apply** toggle for power users

**Li today:** `InspectorPanel`, `PropertyRow`, `ui_inspector_section_count()` on `import ui`; `InspectorRow` on `import gui` (stubs).  
**Li gap:** No generated inspector from Li types yet.  
**Next:** Map `lic check --format=json` diagnostics into inspector rows (PH-AGENT).

**Offline:** `downloads/paraview-properties-panel.html`  
**Tavily:** `downloads/research-scientific-editor-ui.md` (dock persist, tab stacks, pane-set presets, localized Apply)

---

## UX-05 — Timeline & playback

**Incumbents:** UE Sequencer, Blender timeline.

**Patterns to steal**

- Transport controls bound to sim clock (`sim.step`)
- Scrub bar with frame-accurate preview

**Li gap:** `seq` package stub — tie to tier-2 time-step benches.

---

## UX-06 — Scientific visualization

**Incumbents:** ParaView pipeline, color maps, slice widgets.

**Patterns to steal**

- Pipeline browser + active source highlighting
- Scalar coloring with legend bar
- Split views linked by camera

**Li gap:** Tier-2 verify on fields; no in-viewport color map UI.  
**Bench:** `md_lennard_jones`, `heat_equation_2d` in `verify.py`.

**Offline:** `downloads/paraview-properties-panel.html`

---

## UX-07 — Drug-discovery stage workflow (LITL)

**Incumbents:** Roche **Lab in a Loop** (target → screen → lead opt → clinic); Recursion **LOWE** (natural language + charts in one UI).

**Patterns to steal**

- **Stage-colored chrome** — hypothesis | generate | DFT | lab | ML panels (maps to `layout_role_*`)
- Loop visualization: lab data → retrain → next prediction (dashboard cards, not just logs)
- NL command bar with structured tool calls (LOWE) → Li: MCP tools + mandatory `lic build`

**Li today:** `adaptive_layout_hd()` fixed 1280×720 rects; composable `import_ui_adaptive_layout.li`.  
**Next:** Wire stages to `sim.drug_design` composables; QM job queue panel.

**Sources:** Roche digi-day 2024 PDF (web), [LOWE blog](https://www.valencelabs.com/lowe-an-llm-orchestrated-workflow-engine-unleashing-the-full-power-of-recursions-data-and-tools/)

**Tavily report (2026-05-23):** `downloads/research-drug-discovery-ui.md` — steal list:

| Incumbent | Layout pattern | Li mapping |
|-----------|----------------|------------|
| Benchling | Left nav + notebook + Automation Designer DAG | `layout_role_*` + future workflow graph |
| LiveDesign | LiveReport spreadsheet + KNIME canvas | Inspector tables bound to sim/chem rows |
| Recursion OS | Phase map (biology → design → clinic) | Extend `adaptive_layout_hd` to phase tabs |
| LOWE | NL console + inline charts | PH-AGENT MCP + `lic build` errors in-panel |

---

## UX-08 — AM / slicer workflow

**Incumbents:** PrusaSlicer, Cura, Bambu Studio.

**Patterns to steal**

- Large central plater + left tool toolbar + right print/filament/printer profiles
- **Slice now** → auto-switch to layer preview (TAB toggle)
- Simple / Advanced / Expert mode for settings depth

**Li target:** ≤3 clicks to export print job (PH-UX).  
**Li gap:** No plater UI — `sim.additive` composables only.

**Offline:** `downloads/prusa-ui-overview.html`

---

## UX-09 — Export & handoff

**Incumbents:** Prusa **Export G-code** + **Export to SD/USB** when media detected; publication bundles (PH-PUB).

**Patterns to steal**

- Primary CTA bottom-right on plater
- Safe eject + path memory for removable media
- Repro zip with manifest (Li: `studio.publish`)

**Li gap:** RFC stub only.

---

## UX-10 — Profile switching

**Incumbents:** CARLA/Isaac configs; UE project maps; Li `sim_*` profiles in vision doc.

**Patterns to steal**

- Visible profile badge in title bar
- Reload warnings when switching physics backends

**Li gap:** Document profile → package set in `world-studio.toml`; MCP `sim_set_profile`.

---

## UX-11 — Agent / MCP surfaces

**Incumbents:** Recursion LOWE; generic Copilot side panels.

**Patterns to steal**

- Chat + structured cards for tool results
- Every agent mutation ends in `lic build` / `lic check` with surfaced errors
- `studio_adaptive_layout` tool (vision §18) → call `adaptive_layout_hd` / future parametric API

**Li gap:** PH-AGENT RFC stub; cursor-sdk wiring in separate repo overlay.

---

## UX-12 — Accessibility

**Incumbents:** WCAG 2.2 AA for web chrome; game-specific exemptions for viewport.

**Patterns to steal**

- Focus order through dock regions
- High-contrast `studio.design` token pair
- Keyboard equivalents for transport + palette

**Li gap:** Not audited — track in PH-UX UX-4 phase.

---

## UX-13 — Performance perception

**Targets (PH-UX):** Viewport ≥60 fps; panel switch &lt;100 ms.

**Measurement**

- Instrument `ui_frame_begin` / panel toggles in future HUD
- Do not claim perf until `world-studio.toml` timed rows exist

---

## UX-14 — Onboarding & templates

**Incumbents:** UE templates; Blender default scenes.

**Patterns to steal**

- `world_scaffold` MCP → prewired profile + sample sim
- First-run: pick vertical (game / science / drug / AM) → sets `studio.adaptive` layout

**Li gap:** HTML demo only — native `li-studio` scaffold pending (PH-GD-1).

---

## Agent checklist (before merging UI PR)

- [ ] Cited dimension ID(s) and incumbent pattern stolen
- [ ] Updated `verticals.toml` row if domain workflow changed
- [ ] Composable or `compile_ok` test for new `import ui` / `gui` surface
- [ ] No httpd / tier-5 scope creep
- [ ] Ran `./scripts/fetch-competitive-intel.sh` if URLs in manifest changed
