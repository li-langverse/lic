# UI/UX competitive analysis — every dimension

**Status:** Canonical cross-domain UX research (2026-05)  
**Purpose:** Pull UI/UX material from competitors **per industry dimension**, analyze what works, map to **Li World Studio** (one shell, four killers + proof).  
**Media:** [media-catalog.md](media-catalog.md) · [recent-published.md](recent-published.md) · `./scripts/checkout-competitive-media.sh` → `media/local/`  
**Product mapping:** [unified-studio-ux-vision.md](../unified-studio-ux-vision.md) · [product-north-star.md](../product-north-star.md)

---

## How to use this doc

1. Pick your **`engine.profile`** (or workspace).  
2. Read the **dimension section(s)** below.  
3. Capture missing screenshots into `media/local/<competitor>/` ([CAPTURE.md](CAPTURE.md)).  
4. Implement patterns via **same dock DNA** — only panel *content* changes ([unified-studio-ux-vision](../unified-studio-ux-vision.md)).

**Legend:** ✅ steal pattern · ⚠️ steal with caution · ❌ avoid · ➕ Li beats them

---

## Dimension map (quick index)

| # | Dimension | Primary competitors | Li profile / surface |
|---|-----------|---------------------|-------------------|
| 1 | [Game engines](#1-game-engines--creator-platforms) | UE, Unity, Godot | `game` · viewport |
| 2 | [Creator platforms](#1-game-engines--creator-platforms) | Roblox, UEFN | `game` · GUI + agent |
| 3 | [Scientific visualization](#2-scientific-visualization) | ParaView, MATLAB, VisIt | `sim_scientific` · viewport |
| 4 | [CAE / multiphysics GUI](#3-cae--multiphysics-simulation-gui) | COMSOL, ANSYS, SimScale | `sim_scientific` · inspector |
| 5 | [CFD / MD workflows](#4-cfd--md-workflow-ux-cli--gui) | OpenFOAM, GROMACS, Fluent | `sim_scientific` · bench panel |
| 6 | [CAD & mechanical](#5-cad--mechanical-design) | Fusion, SolidWorks, Onshape | import + AM / `sim_additive` |
| 7 | [Additive / slicers](#6-additive-manufacturing--slicers) | Cura, Prusa, Bambu Studio | `sim_additive` · export wizard |
| 8 | [DCC & modeling](#7-dcc--3d-modeling) | Blender, Maya | `li-scene` · assets in |
| 9 | [Procedural graphs](#8-procedural--node-graph-ux) | Houdini, ComfyUI, Blueprint | `canvas` |
| 10 | [Cinematic & video](#9-cinematic--video-editing) | UE Sequencer, Blender VSE, Resolve | `seq` · bottom timeline |
| 11 | [Robotics & twin](#10-robotics--digital-twin) | Gazebo, Isaac Sim, RViz | `sim_robotics` · viewport |
| 12 | [Design & whiteboard](#11-design-tools--infinite-canvas) | Figma, Miro, tldraw | `canvas` |
| 13 | [IDE & agents](#12-ide-notebooks--agents) | Cursor, VS Code, Jupyter | ⌘K · transcript · MCP |
| 14 | [Lab / bio / chem](#13-lab--bio--cheminformatics-ux) | Benchling, Maestro-class, LITL | `sim_drug_design` · adaptive |

---

## Cross-cutting UI DNA (all dimensions)

Every serious tool converges on:

```text
[Modes / profile] [Run ▶] [Agent?] [⌘K] [Publish]
[Hierarchy / graph]  [ PRIMARY CANVAS ]  [Inspector / props]
[Timeline | runs | stages | logs | agent transcript]
```

| Pattern | Best-in-class examples | Li rule |
|---------|------------------------|---------|
| Largest central surface | UE viewport, ParaView, Figma | Viewport **or** canvas — never cramped inspector |
| Tree + inspector | All | Typed Li fields + **units** for engineering |
| Bottom time axis | Sequencer, VSE, COMSOL study | Timeline **or** bench **or** LITL strip |
| Command palette | Cursor, UE | `ui_cmd_*` = human + agent |
| Run → review → export | Slicers, ANSYS report | **Gate + validity + hash** on every path |
| Status / progress | ComfyUI nodes, cloud solvers | Node color + toolbar chip |

➕ **Li-only chrome:** gate chip · validity badge · oracle id · publish hash — visible on **all** profiles.

---

## 1. Game engines & creator platforms

### Competitors & UI material

| Product | UI material | Local captures |
|---------|-------------|----------------|
| **Unreal Engine** | UE-VID-*, UE-DOC-*, `media/local/unreal-engine/` | Sequencer, editor layout |
| **Unity** | UN-VID-*, UN-DOC-*, `media/local/unity/` | UI Builder, Timeline docs |
| **Godot** | GO-*, `media/local/godot/` | Editor intro webp set |
| **Roblox Studio** | RB-DOC-*, RB-VID-*, `media/local/roblox/` | Toolbar, Explorer, docking |
| **UEFN** | FN-VID-*, FN-NEWS-* | Tutorials, creator news |

One-pagers: [by-competitor/](by-competitor/)

### What works (UX)

| Pattern | Who | Why it works |
|---------|-----|--------------|
| Viewport-first | UE, Unity, Godot | Spatial reasoning — world is the product |
| Outliner ↔ selection | All | One click to scope edits |
| Play toolbar cluster | All | Run is muscle memory |
| Mode tabs | Roblox | Reduces ribbon overload |
| Dock / float / pin | Godot, Roblox | Multi-monitor labs |
| Sequencer bottom | UE | Cinematic without leaving world |
| UI Builder canvas | Unity | WYSIWYG HUD; separates layout from code |
| Style Editor | Roblox | Creators theme without code |
| Embedded game window | Godot 4.4+ | Edit/play same tree — low context switch |

### Pain points

- Binary assets (UE `.uasset`) — agents and git hate it  
- Unity IMGUI vs UI Toolkit split — two UIs  
- Roblox: powerful but runtime-only validation  
- Overloaded toolbars — beginners drown  

### Learn for Li

| | Action |
|---|--------|
| ✅ | Viewport-first; outliner + inspector; play cluster; workspace tabs |
| ✅ | Bottom `seq` panel; `gui` theme editor; Godot-like same-tree HUD |
| ✅ | ⌘K palette; agent dock (Roblox Assistant + Cursor) |
| ⚠️ | Blueprint visual scripting — use **canvas → Li**, not opaque graphs |
| ❌ | Widget blueprint as source of truth |
| ➕ | Gate before ▶; validity on bench overlay; diffable `world.li` |

### Li mapping

| Competitor UI | Li |
|---------------|-----|
| Outliner | Scene tree + `canvas` node list |
| Details / Inspector | Li types + replication fields |
| Sequencer | `seq/*.li` + cinematic workspace |
| UI Builder / UMG | `gui/*.li` editor → emits Li |
| Roblox UI tab | `gui.theme.li` + Style panel |
| Assistant | `ui_agent_*` + **mandatory `lic build`** |

---

## 2. Scientific visualization

### Competitors & UI material

| Product | Typical UI | Material to capture |
|---------|------------|---------------------|
| **ParaView** | Pipeline browser, 3D view, color map editor | paraview.org docs; local `media/local/paraview/` |
| **MATLAB** | Live Editor, plots, toolstrip | mathworks.com product pages |
| **VisIt** | Similar pipeline + plots | wci.llnl.gov VisIt docs |
| **Kitware/trame** | Web PV — pipeline + viewport | For agent/web patterns only |

*Add catalog IDs `PV-DOC-01`, `MAT-DOC-01` when capturing.*

### What works

| Pattern | Why |
|---------|-----|
| **Pipeline browser** (sources → filters → display) | Makes dataflow explicit |
| **3D view + 2D slice** linked | Engineers trust cross-sections |
| **Color map / legend** always visible | Results readable at a glance |
| **Time slider** for transient fields | Standard mental model |
| **Screenshot / export scene** | Papers need figures |

### Pain points

- VTK-brain — steep learning curve  
- Disconnected from **solver setup** (post-process only)  
- No **build gate** — easy to plot wrong timestep  
- Agents have no stable pipeline IDs  

### Learn for Li

| | Action |
|---|--------|
| ✅ | Field overlay in **same** `li-render` viewport; legend + time scrub |
| ✅ | Pipeline as **canvas nodes** (Source → Sim → Display) compiling to `sim_scientific` |
| ✅ | Export figure → PH-PUB with field CSV + hash |
| ❌ | Separate VTK-only app fork |
| ➕ | Validity line (drift, checksum) under legend — ParaView doesn’t show “physics ok” |

### Li mapping

`sim.viz` + scientific workspace · bench panel shows **oracle name** · bottom strip = run history not just animation.

---

## 3. CAE / multiphysics simulation GUI

### Competitors & UI material

| Product | UI hallmarks | Capture targets |
|---------|--------------|-----------------|
| **COMSOL** | Model Builder tree, Study, Parameters, Results | Model wizard, BC dialog, study sweep |
| **ANSYS** | Mechanical / Fluent workspaces, outline, details | Mesh, setup, solution, report |
| **SimScale** | Cloud CAE — project tree, run status | Web progress UX |
| **Altair / Abaqus** | Solver decks + GUI (varies) | Report + job monitor patterns |

### What works

| Pattern | Why |
|---------|-----|
| **Study / step tree** | BCs, materials, mesh, solver, results — ordered workflow |
| **Parameter sweep table** | Design exploration is core job |
| **Inspector for BCs** | Focused forms beat graph for constraints |
| **Run monitor + logs** | Long runs need trust |
| **Report generation** | PDF/HTML for sign-off culture |

### Pain points

- Opaque project files  
- **Hours-long runs** with weak repro metadata  
- GUI tied to one vendor solver  
- Agents can’t safely edit BCs  

### Learn for Li

| | Action |
|---|--------|
| ✅ | Study tree → `canvas` pipeline or `studio.adaptive` stages |
| ✅ | Parameter table in inspector (Li constants, units) |
| ✅ | Run panel: progress + **validity** + repro id (not just “Complete”) |
| ⚠️ | Full meshing UI — defer; import mesh, sim on occupancy/fields |
| ❌ | Claim certified CAE without oracle rows |
| ➕ | Diffable `world.li` / sim config; `lic build` on parameter types |

### Li mapping

`sim_scientific` profile · inspector = BCs/materials (typed) · publish = PH-PUB not screenshot.

---

## 4. CFD / MD workflow UX (CLI + GUI)

### Competitors & UI material

| Product | UX model | Material |
|---------|----------|----------|
| **OpenFOAM** | Case folder, dictionaries, ParaView post | OpenFOAM User Guide figures |
| **GROMACS** | `.mdp` + `.top` + logs + `gmx` tools | Manual + typical case layout |
| **LAMMPS** | Input script + dump | docs.lammps.org |
| **Fluent / CFX** | GUI setup (ANSYS family) | Overlap dimension 3 |

### What works

| Pattern | Why |
|---------|-----|
| **Case directory manifest** | Repro culture — everything in a folder |
| **Log tail + residual plots** | Convergence visibility |
| **Decompose / parallel** job UI | HPC users need cluster hooks (later) |
| **Post → ParaView** one-click mental model | Expected pipeline |

### Pain points

- CLI terror for non-HPC users  
- **No unified Studio** — 5 tools per paper  
- Easy to run wrong `mdp` / `controlDict`  

### Learn for Li

| | Action |
|---|--------|
| ✅ | **Case manifest** = `studio.toml` + bench row IDs in publish bundle |
| ✅ | Residual / drift chart in bottom panel (from validity) |
| ✅ | One-click “open field in viewport” from bench result |
| ❌ | Hide solver config in binary |
| ➕ | Tier-2 oracles named in UI (heat_2d, lj_cluster) — honesty vs “we are OpenFOAM” |

### Li mapping

Bench-first UX for scientific profile; CLI power users get **Li source** instead of dict syntax when they want.

---

## 5. CAD & mechanical design

### Competitors & UI material

| Product | UI hallmarks | Capture |
|---------|--------------|---------|
| **Fusion 360** | Timeline tree, sketch canvas, simulate tab | autodesk.com videos |
| **SolidWorks** | Feature tree, dimension-driven sketch | Dassault media |
| **Onshape** | Web CAD, version/fork UI | Collaboration patterns |
| **FreeCAD / OpenSCAD** | Parametric tree / code CAD | Scriptable UX — closest to Li philosophy |

### What works

| Pattern | Why |
|---------|-----|
| **Feature tree** | History-based modeling clarity |
| **Sketch → extrude** | Constraint solving feedback (dims on canvas) |
| **Assembly mates** | Engineers think in relationships |
| **Simulate tab** | One brand, setup FEA in familiar chrome |
| **Export STEP/STL** | Manufacturing handoff |

### Pain points

- PDM / license hell  
- **Parametric history breaks** on big edits  
- Simulation add-on ≠ same file truth for agents  

### Learn for Li

| | Action |
|---|--------|
| ✅ | **Parametric logic in Li** (`def bracket(thickness: mm)`) not B-rep kernel |
| ✅ | Import STEP/glTF → `li-assets` → sim/AM |
| ✅ | Pre-flight before manufacturing export |
| ❌ | Build SolidWorks-class sketcher in v1 |
| ➕ | Git-diffable parameters + sim pass before STL/G-code |

### Li mapping

No CAD workspace — **import + scene graph + AM/scientific profile**. Inspector shows mesh/material from assets.

---

## 6. Additive manufacturing & slicers

### Competitors & UI material

| Product | UI hallmarks | Capture |
|---------|--------------|---------|
| **Cura** | 3D preview, settings sidebar, slice → preview | UltiMaker UI tours |
| **PrusaSlicer** | Plater, paint-on supports, G-code preview | prusa3d.com |
| **Bambu Studio** | Multi-plate, AMS, flow calibration | Modern slicer UX |

### What works

| Pattern | Why |
|---------|-----|
| **3D plater** | Nests parts — spatial confidence |
| **Slice preview slider** | Layer inspection before print |
| **Material / profile presets** | ≤3 clicks to “good enough” |
| **Estimated time & material** | User trusts send-to-printer |
| **Warnings panel** | Overhangs, collisions |

### Pain points

- **No physics sim** in slicer — warp failures after print  
- Settings maze (100+ knobs)  
- No repro hash for “this G-code matches that sim”  

### Learn for Li

| | Action |
|---|--------|
| ✅ | **3-click export wizard** (review → pre-flight → send) |
| ✅ | Preset dropdown (printer profile) |
| ✅ | Warnings + **sim pass required** |
| ➕ | `require_sim_pass` + audit log — slicers don’t gate on thermal validity |

### Li mapping

`sim_additive` · [li-sim-additive-rfc](../specs/li-sim-additive-rfc.md) · export drawer in Publish workspace.

---

## 7. DCC & 3D modeling

### Competitors & UI material

| Product | UI material |
|---------|-------------|
| **Blender** | BL-*, `media/local/blender/`, workspaces, VSE |
| **Maya / 3ds Max** | Industry rigging/viewport — capture from Autodesk learning pages |
| **ZBrush** | Sculpt UI — not primary Li target |

### What works

| Pattern | Why |
|---------|-----|
| **Workspaces** (Layout, Modeling, UV, Animation) | Mode-specific tools without new app |
| **Outliner + collections** | Scene organization at scale |
| **Non-destructive modifiers stack** | Experimentation |
| **Timeline + NLA** | Animation literacy |

### Pain points

- Not a game **runtime**  
- `.blend` binary — bad for agents/git  

### Learn for Li

| | Action |
|---|--------|
| ✅ | Workspace presets (game / sim / cinematic) — Blender lesson |
| ✅ | Import glTF; animate in `anim/*.li`; don’t rebuild Blender |
| ❌ | In-engine mesh modeling v1 |
| ➕ | Author in Li, preview in Studio, publish with hash |

### Li mapping

`li-scene` + `li-anim` · Blender for external mesh only.

---

## 8. Procedural & node graph UX

### Competitors & UI material

| Product | UI material |
|---------|-------------|
| **Houdini** | Node graph, network tabs, perf bar — sidefx.com |
| **ComfyUI** | Node queue, color status, PNG workflow | github + screenshots |
| **UE Blueprint** | Typed pins, compile errors in graph |
| **Grasshopper** | Parametric CAD graph — Rhino ecosystem |

### What works

| Pattern | Why |
|---------|-----|
| **Nodes + wires** | Dataflow obvious |
| **Status color** (dirty/cooking/done/error) | At-a-glance pipeline health |
| **Group / subnet** | Scale to 500+ nodes |
| **Mini preview on node** | Reduces context switch |
| **Compile errors on graph** | Fail fast |

### Pain points

- **Spaghetti** without grouping  
- Blueprint not git-friendly  
- ComfyUI: no engineering validity  

### Learn for Li

| | Action |
|---|--------|
| ✅ | `canvas.li` with typed `CanvasLinkKind` |
| ✅ | Node states: pending / building / pass / fail (**gate**) |
| ✅ | Subgraphs compile to `world.li`, `seq`, `gui`, sim profile |
| ➕ | `lic build` on selection — Houdini/Comfy don’t unify sim+game |

### Li mapping

Default workspace for drug/bio/agent · [li-canvas-agentic-rfc](../specs/li-canvas-agentic-rfc.md).

---

## 9. Cinematic & video editing

### Competitors & UI material

| Product | UI material |
|---------|-------------|
| **UE Sequencer** | UE-DOC-*, `media/local/unreal-engine/` |
| **Unity Timeline** | UN-DOC-02/03 |
| **Blender VSE** | BL-DOC-*, `media/local/blender/` |
| **DaVinci Resolve** | Timeline + color page — blackmagic design media |

### What works

| Pattern | Why |
|---------|-----|
| **Horizontal timeline** | Industry standard |
| **Tracks per object/shot** | Parallel editing |
| **Scrub + transport** | Muscle memory |
| **Export presets** | YouTube / ProRes / 1080p30 |
| **Render queue** | Batch overnight |

### Pain points

- Opaque project formats  
- **No determinism hash** in consumer tools  
- MRQ complexity in UE  

### Learn for Li

| | Action |
|---|--------|
| ✅ | Bottom timeline; shot list; camera tracks |
| ✅ | Export presets + progress + **frame hash** |
| ⚠️ | Color grading suite — out of scope v1 |
| ➕ | `seq` in Li + reproducible publish bundle |

### Li mapping

`li-seq` · cinematic workspace · `studio.publish_video`.

---

## 10. Robotics & digital twin

### Competitors & UI material

| Product | UI material |
|---------|-------------|
| **Gazebo / Ignition** | 3D view, model insert, joint debug — gazebosim.org |
| **NVIDIA Isaac Sim** | Viewport, sensors, synthetic data — docs.omniverse |
| **RViz / Foxglove** | Robot viz + time series | ROS community |
| **CARLA** | Driving sim UI — compare `sim_automotive` profile |

### What works

| Pattern | Why |
|---------|-----|
| **3D world + robot articulation** | Spatial debug |
| **Joint slider / TF tree** | Kinematics intuition |
| **Sensor preview panels** | Camera/lidar trust |
| **Play/pause sim** | Like game engine |

### Pain points

- **Separate from game engine** (Isaac vs Unity)  
- ROS graph not agent-friendly  

### Learn for Li

| | Action |
|---|--------|
| ✅ | Same viewport/play loop as `game` |
| ✅ | TF tree in outliner; joint inspector |
| ✅ | Optional ROS2 bridge — not duplicate physics |
| ➕ | `sim_step` validity + determinism tier on replay |

### Li mapping

`sim_robotics` · [li-sim-robotics-rfc](../specs/li-sim-robotics-rfc.md).

---

## 11. Design tools & infinite canvas

### Competitors & UI material

| Product | UI material |
|---------|-------------|
| **Figma** | FI-*, `media/local/figma/` |
| **Miro / FigJam** | Infinite board, sticky, voting — for collab patterns only |
| **tldraw** | Minimal infinite canvas SDK | Reference for pan/zoom perf |

### What works

| Pattern | Why |
|---------|-----|
| **Infinite pan/zoom** | Ideas don’t fit A4 |
| **Sections / frames** | Structure for teams |
| **Minimal chrome (UI3)** | Canvas is hero |
| **Multiplayer cursors** | Collab delight (optional Li v2) |
| **Inspect / dev handoff** | Design → code |

### Pain points

- **No runtime / sim**  
- Figma Make without engineering validity  

### Learn for Li

| | Action |
|---|--------|
| ✅ | Infinite `gui.canvas` @ 60fps (P10 plan) |
| ✅ | Sections = `canvas.region` |
| ❌ | Pixel pushing as end goal |
| ➕ | Compile to Li + gate — design tools stop at handoff |

### Li mapping

Canvas workspace · Config 2025 lesson: prompt-to-build → our **agent + `lic build`**.

---

## 12. IDE, notebooks & agents

### Competitors & UI material

| Product | UI material |
|---------|-------------|
| **Cursor** | ⌘K, agent, composer, rules — cursor.com |
| **VS Code** | Command palette, problems panel, extensions |
| **Jupyter** | Cell run order, outputs inline — scientific UX |
| **MATLAB Live Editor** | Mixed prose + plots |

### What works

| Pattern | Why |
|---------|-----|
| **Command palette** | Discoverability |
| **Problems / diagnostics panel** | Errors actionable |
| **Transcript / chat with apply** | Agent loop |
| **Diff before apply** | Trust |
| **Inline outputs** | Notebook literacy for scientists |

### Pain points

- Agents without **domain validity** (code runs, physics wrong)  
- Notebooks **non-deterministic** run order  

### Learn for Li

| | Action |
|---|--------|
| ✅ | ⌘K + `ui_cmd_*`; transcript; diagnose → problems panel |
| ✅ | Agent applies **Li patches**, not random scripts |
| ✅ | Notebook-like **bench cells** with validity inline |
| ➕ | `lic diagnose` JSON + gate chip — stricter than Copilot |

### Li mapping

[agent-first-gui-research.md](../agent-first-gui-research.md) · MCP exports cmd table.

---

## 13. Lab / bio / cheminformatics UX

### Competitors & UI material

| Product | UI material |
|---------|-------------|
| **Benchling** | Notebook, registry, workflow — benchling.com product tour |
| **Schrödinger Maestro** | Mol viewer, project table, job monitor |
| **Roche LITL** (class) | Stage-gated pipelines — competitive-bio plan |
| **SnapGene / Geneious** | Plasmid map UX — for bioeng registry inspiration |

### What works

| Pattern | Why |
|---------|-----|
| **Stage wizard** (Design → Build → Test → Learn) | Matches lab mental model |
| **Registry tables** (constructs, strains) | Data backbone |
| **Role-based layouts** | Scientist vs automation engineer |
| **Job queue + status** | QM/MD long runs |
| **ELN integration** | Compliance narrative |

### Pain points

- Siloed from **simulation engine**  
- Agents on ELN without compute proof  

### Learn for Li

| | Action |
|---|--------|
| ✅ | `studio.adaptive` per LITL/DBTL stage |
| ✅ | Canvas for pipeline + `bioeng` nodes |
| ✅ | Job panel ties to `li-chem` / `li-ml` with repro id |
| ➕ | Same gate + validity as game/sim on every stage advance |

### Li mapping

`sim_drug_design` · [competitive-bioengineering-plan](../competitive-bioengineering-plan.md).

---

## Master matrix: dimension × UI pattern

| UI pattern | 1 Game | 2 SciVis | 3 CAE | 4 CFD/MD | 5 CAD | 6 AM | 7 DCC | 8 Graph | 9 Cine | 10 Robo | 11 Design | 12 IDE | 13 Lab |
|------------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Viewport center | ● | ● | ● | ○ | ● | ● | ● | ○ | ○ | ● | ○ | ○ | ○ |
| Infinite canvas | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ● | ○ | ○ | ● | ○ | ● |
| Hierarchy left | ● | ● | ● | ○ | ● | ○ | ● | ● | ● | ● | ○ | ○ | ● |
| Inspector right | ● | ● | ● | ○ | ● | ● | ● | ● | ● | ● | ○ | ○ | ● |
| Bottom timeline | ● | ● | ● | ○ | ○ | ○ | ● | ○ | ● | ● | ○ | ○ | ● |
| Command palette | ● | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ● | ○ |
| Agent dock | ● | ○ | ○ | ○ | ○ | ○ | ○ | ● | ○ | ○ | ○ | ● | ○ |
| Run monitor | ○ | ● | ● | ● | ○ | ● | ○ | ● | ● | ● | ○ | ○ | ● |
| Export wizard | ○ | ● | ● | ○ | ● | ● | ○ | ○ | ● | ○ | ○ | ○ | ● |
| **Li validity chrome** | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ | ➕ |

● = strong incumbent pattern · ○ = weaker / optional · ➕ = Li differentiator (all rows)

---

## Synthesis: what Li implements once

| # | Unified pattern | Source dimensions |
|---|-----------------|-------------------|
| 1 | Same dock layout, adaptive innards | All |
| 2 | Viewport **or** canvas as hero | 1,2,8,11,13 |
| 3 | Bottom strip swaps: seq / bench / LITL | 1,3,4,9,13 |
| 4 | ⌘K + agent transcript + plan node | 1,8,12,13 |
| 5 | Inspector: Li types + units | 3,4,5,10,13 |
| 6 | Publish drawer: video, bundle, G-code | 6,9,3,13 |
| 7 | Gate + validity + hash **always visible** | **Li only** — [product-north-star](../product-north-star.md) |

---

## Capture backlog (UI material to pull)

| Priority | Dimension | Capture into `media/local/` |
|----------|-----------|----------------------------|
| P0 | CAE | COMSOL Model Builder + Study (web) |
| P0 | SciVis | ParaView pipeline + color map |
| P0 | Slicer | Cura plater + slice preview |
| P1 | IDE | Cursor agent + palette (marketing) |
| P1 | Houdini | Network editor screenshot |
| P1 | Gazebo | Joint debug view |
| P2 | Fusion | Timeline + simulate tab |
| P2 | Benchling | Registry + notebook |

---

## Related docs

- [analysis.md](analysis.md) — executive synthesis  
- [unified-studio-ux-vision.md](../unified-studio-ux-vision.md) — one shell implementation  
- [product-north-star.md](../product-north-star.md) — four killers + proof  
- [li-native-gui-plan.md](../plans/li-native-gui-plan.md) — build phases G0–G8

**Maintain:** When adding a competitor URL, add a row here **and** [catalog.json](catalog.json) with `dimension` field.
