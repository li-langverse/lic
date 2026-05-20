# Unified Studio UX — killer human + agent UI (all domains)

**Status:** Canonical product UX vision (2026-05)  
**Audience:** PH-UX, PH-AGENT, PH-SIM, PH-GD  
**Related:** [world-studio-vision.md](world-studio-vision.md) · [li-native-gui-plan.md](plans/li-native-gui-plan.md) · [agent-first-gui-research.md](agent-first-gui-research.md) · [competitive-intel/analysis.md](competitive-intel/analysis.md)

---

## 1. Our vision (different from everyone else)

Incumbents **fork products** (game engine vs CFD GUI vs CAD vs LIMS vs slicer) and **bolt on AI** to opaque projects.

**Li World Studio** is one shell where:

| Their split | Our unity |
|-------------|-----------|
| Unreal + ParaView + Excel reports | **One viewport** — game, field viz, robot cell, same `li-render` |
| SolidWorks + ANSYS + Word | **One pipeline** — `world.li` → sim profile → **publish bundle** with hash |
| Figma + Jira + Copilot | **One canvas** — spatial graph that **compiles**, not a whiteboard |
| Roblox Assistant + runtime errors | **One gate** — agent actions require **`lic build`** / validity, not “looks fine” |
| Blender + After Effects + slicer | **One language** — `scene`, `anim`, `seq`, `gui`, `canvas` in **Li** |

**Killer UI** here means: *familiar chrome from the best tools in each industry*, but **one interaction model** for humans and agents, with **proof before play/export**.

---

## 2. What works best (cross-domain) — steal the pattern, not the app

### 2.1 Spatial + hierarchical (every serious tool)

| Pattern | Games | Sim / CAE | CAD / AM | DCC | Li surface |
|---------|-------|-----------|----------|-----|------------|
| **Largest canvas** | 3D viewport | Field/mesh view | Model view | 3D view | **Center: viewport OR infinite canvas** |
| **Hierarchy** | Outliner | Model tree / zones | Feature tree | Outliner | **Left: scene + canvas nodes** |
| **Inspector** | Details | Properties / BCs | Parameters | Item props | **Right: typed Li fields** |
| **Timeline** | Sequencer | Run steps / plots | — | Dope sheet / VSE | **Bottom: `seq` / lab stage / bench run** |
| **Browser** | Content | Materials / meshes | Parts / assemblies | Assets | **Assets + manifests** |

**Rule:** Same dock geometry for **every** `engine.profile` — only **panel contents** change (adaptive).

### 2.2 Modes & workspaces (reduce cognitive load)

| Pattern | Who does it well | Li |
|---------|------------------|-----|
| **Mode tabs** | Roblox (Home/Model/UI/Script), Blender workspaces | `studio.workspace_*` — Game · Sim · Cinematic · Canvas · Publish |
| **Profile switch** | Unity build targets, COMSOL study types | `sim_set_profile` + **one-click** workspace swap |
| **Stage-driven UI** | Drug LITL, bio DBTL | **`studio.adaptive`** — show only panels for current pipeline stage |
| **Play vs edit** | All engines | Toolbar state + **gate badge** (build pass/fail) |

**Rule:** ≤3 clicks for primary flows (export, run bench, play, publish) — [PH-UX](world-studio-vision.md#17-ph-ux--killer-uiux).

### 2.3 Command + agent (modern default)

| Pattern | Who | Li |
|---------|-----|-----|
| **Command palette** | VS Code, Cursor, UE | `ui_cmd_*` — humans fuzzy-search; agents call **IDs** |
| **Agent dock + transcript** | Cursor, Roblox Assistant | `UiAgentAction` + roles + **linked diagnose** |
| **Plan before execute** | Roblox agentic 2026 | **Canvas “Plan” node** → editable steps → apply with gate |
| **Node graph status** | ComfyUI, Houdini, Blueprint | Canvas nodes: pending / building / green / failed |

**Rule:** Agents never rely on pixel coordinates — stable IDs in manifest ([agent-first-gui-research.md](agent-first-gui-research.md)).

### 2.4 Proof & publish (engineering + science win here)

| Pattern | Who | Li (better) |
|---------|-----|-------------|
| **Pre-flight** | Slicers, AM, aviation checklists | **`require_sim_pass`** before export/print |
| **Run manifest** | OpenFOAM case, GROMACS mdp | **`studio.toml` + bench row IDs** in publish bundle |
| **Report export** | ANSYS, ParaView screenshots | **PH-PUB** — figures + CSV + repro hash, not ad-hoc PNG |
| **Versioned source** | CAD PDM (painful) | **Git-diffable `*.li`** |

**Rule:** Every “Ship / Export / Publish” button runs **`lic build`** (or profile-specific validity) first.

### 2.5 Creator & in-app UI (games + platforms)

| Pattern | Who | Li |
|---------|-----|-----|
| **Style tokens** | Roblox Style Editor, USS | `gui/theme.li` |
| **Screen HUD** | UMG, UI Toolkit, Godot Control | `gui/*.li` in **player** |
| **Sandboxed commands** | Roblox | `gui.cmd_*` whitelist |

---

## 3. One shell — five surfaces (not five products)

Humans and agents use the **same five surfaces**; profile changes **defaults**, not layout DNA:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│ Toolbar: [Workspace ▾] [Profile ▾] [▶ Play] [⎋ Agent] [⌘K] [Publish]   │
├──────────┬──────────────────────────────────────────────┬───────────────┤
│ Outliner │  PRIMARY SURFACE (pick one as default)        │  Inspector    │
│ + Canvas │  • Viewport 3D (game, robot, field overlay)   │  Li types     │
│  nodes   │  • Infinite canvas (graphs, plans, pipelines)  │  + units      │
├──────────┴──────────────────────────────────────────────┴───────────────┤
│ Bottom: Timeline | Bench runs | Lab stages | Logs | Agent transcript     │
└─────────────────────────────────────────────────────────────────────────┘
```

| Surface | Default for profile | Human job | Agent job |
|---------|---------------------|-----------|-----------|
| **Viewport** | `game`, `sim_robotics`, `sim_scientific` | See world/fields | Read stats overlay, camera refs |
| **Canvas** | `sim_drug_design`, agents, complex pipelines | Wire worlds ↔ seq ↔ sim | Place nodes, link, **compile selection** |
| **Cinematic** | `seq` editing | Shots, cameras | Patch `seq/*.li` by `shot_id` |
| **GUI editor** | `gui` authoring | HUD layout | Patch `gui/*.li` by `widget_id` |
| **Publish** | all | Export video / bundle / G-code | Trigger `publish_bundle` after gate |

**Default workspace by profile** (adaptive, overridable):

| `engine.profile` | Default workspace | Bottom panel |
|------------------|-------------------|--------------|
| `game` | Viewport + GUI | Timeline (optional) |
| `sim_scientific` | Viewport + field legend | Bench runs + validity |
| `sim_additive` | Viewport + occupancy | Export wizard |
| `sim_robotics` | Viewport | Joint log / IK |
| `sim_drug_design` / bioeng | **Canvas** + adaptive stage | LITL stage strip |
| Agent-heavy session | **Canvas** | Transcript + diagnose |

---

## 4. How we make it better (not a clone)

| They stop at… | We go further |
|---------------|---------------|
| Pretty viewport | Viewport + **validity badge** (tier-2 row, drift, hash) |
| AI suggests edits | AI **patches Li** + **`lic build`** + transcript |
| Infinite whiteboard | Canvas → **`world.li` / `seq` / `gui` / sim profile** |
| Separate sim app | **Same play button** runs game tick or `sim.step` |
| CAD → export STL blind | **Sim pass** → then 3MF/G-code ([li-sim-additive-rfc](specs/li-sim-additive-rfc.md)) |
| Lab notebook PDF | **Publish bundle** tied to pipeline stage hash |
| Keynote FPS | **Dashboard ratio vs cpp** + named SOTA proxy |

**Positioning sentence:**  
*“World Studio: the workspace where worlds, simulations, cinematics, and HUDs share one Li project — humans get AAA-grade chrome, agents get IDs and gates, both get proof before ship.”*

---

## 5. Agentic UX — unified contract

### 5.1 Human vs agent (one registry)

| Channel | Discovery | Execute | Verify |
|---------|-----------|---------|--------|
| Human | ⌘K palette, menus, drag on canvas | click / shortcut | Play overlay, export dialog |
| Agent | MCP tool list, manifest | `UiAgentAction`, `studio_ai_*` | `lic build`, `lic diagnose`, bench validity |

Same **`ui_cmd_*` / `studio_cmd_*` IDs** — no duplicate “agent API”.

### 5.2 Agent action lifecycle (better than Roblox/Cursor alone)

```text
Intent → Plan (canvas or transcript) → Patch (*.li) → lic build →
  ├─ fail → diagnose JSON → transcript (human or retry)
  └─ pass → Play / Run bench / Export / Publish
```

**UI affordances:**

- **Gate chip** in toolbar (green/red) — always visible  
- **Transcript** dock — plan, patch summary, gate output  
- **Canvas nodes** turn green/red with **last gate message**  
- **No silent apply** — agent patches preview diff (future: inline diff panel)

### 5.3 Domain-specific agent tools (same chrome)

| Domain | Example MCP / cmd | UI feedback |
|--------|-------------------|-------------|
| Game | `world_scaffold`, `ui_cmd_play` | Viewport play |
| Sim | `sim_set_profile`, run `heat_equation_2d` | Bench panel + field colors |
| AM | `am_export_print` | 3-step export wizard |
| Drug/bio | `chem_dft_run`, `studio_adaptive_layout` | Stage strip + adaptive panels |
| Cinematic | patch `seq` track | Timeline highlight |
| Publish | `publish_bundle` | Publish drawer + hash |

---

## 6. Design system — one tokens file, all profiles

| Token layer | File | Used by |
|-------------|------|---------|
| Studio chrome | `studio.design` / theme in `li-ui` | Panels, palette, dock |
| Player HUD | `gui/theme.li` | `li-player` |
| Canvas | `canvas.theme` | nodes, links, sections |
| Status semantics | shared | success / warn / fail / running (agent + bench) |

**Accessibility:** focus order list in `UiFrame` (Godot 4.5 lesson) — WCAG 2.2 AA on chrome ([PH-UX](world-studio-vision.md#17-ph-ux--killer-uiux)).

---

## 7. What we explicitly do not build

| Not us | Instead |
|--------|---------|
| Full mechanical CAD | Import STEP/glTF; parametric logic in **Li** |
| Certified ANSYS killer | Tier-2 oracles + honest scope |
| Pixel Figma clone | **Compile graph** + sim/game |
| Second web app as truth | HTML demo = prototype only; **Li canonical** |

---

## 8. Implementation priorities (UX + agent)

| P | Deliverable | Unifies |
|---|-------------|---------|
| P0 | **Workspace presets** per `engine.profile` | Game + sim + drug |
| P0 | **Gate chip + transcript** in studio chrome | Agent + human trust |
| P0 | **⌘K + `ui_cmd_*` MCP export** | All domains |
| P1 | **Default canvas** for pipeline profiles; viewport for spatial sim | Drug + scientific |
| P1 | **Adaptive bottom strip** (timeline vs bench vs LITL stage) | Cinematic + sim + bio |
| P1 | **Publish drawer** (video / bundle / G-code) with presets + hash | Engineering + creators |
| P2 | **GUI theme editor** (Style Editor class) | Creators |
| P2 | **Plan node** on canvas before agent apply | Roblox-class agentic |
| P2 | **Inspector units** (nm, s, Pa) for scientific profiles | Sim/CAD hygiene |
| P3 | **Inline diff** for agent patches | Cursor-class |

Phases align with [li-native-gui-plan.md](plans/li-native-gui-plan.md) G0–G8.

---

## 9. Competitive intel → this doc

| Intel source | Feeds unified UX |
|--------------|------------------|
| [recent-published.md](competitive-intel/recent-published.md) | Agent + canvas trends (Roblox, Figma, UE) |
| [analysis.md](competitive-intel/analysis.md) | Chrome DNA, scorecard |
| [competitive-landscape.md](competitive-landscape.md) | Profile list (AM, robotics, MD, drug) |
| Numerics SOTA matrix | Bench panel honesty |

**Iterate:** bump “Last updated” when a competitor ships a UX shift (e.g. new Roblox agent mode).

---

## 10. Success metrics (killer UI)

| Metric | Target |
|--------|--------|
| Viewport / canvas pan | ≥60 fps |
| Workspace switch | &lt;100 ms |
| Primary flow | ≤3 clicks |
| Agent patch → visible gate | &lt;2 s (local `lic check`) |
| Publish | Bundle hash + manifest always shown |
| a11y | WCAG 2.2 AA on studio chrome |

---

*This is the UX north star for a unified product. Implementation detail stays in [li-native-gui-plan.md](plans/li-native-gui-plan.md); engine scope stays in [world-studio-vision.md](world-studio-vision.md).*
