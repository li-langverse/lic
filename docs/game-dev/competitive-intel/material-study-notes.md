# Material study notes — local UI pulls → plan improvements

**Generated from:** `./scripts/checkout-competitive-media.sh`  
**Local path:** `media/local/` (gitignored) · index: `media/local/manifest.json`  
**Plans updated:** [li-native-gui-plan.md](../plans/li-native-gui-plan.md) v0.6 · [unified-studio-ux-vision.md](../unified-studio-ux-vision.md)

Open images while reading [ui-ux-by-dimension.md](ui-ux-by-dimension.md).

---

## 1. What we pulled (study set)

| Folder | Files (approx) | Study focus |
|--------|----------------|-------------|
| `godot/` | 22 webp | Editor layout, workspaces, embedded play |
| `roblox/` | 6 | Toolbar, docking, explorer |
| `unity/` | 4 png | UI Builder quadrants |
| `unreal-engine/` | 3+ | Sequencer chrome |
| `capcut/` | 8–12 webp | **4-panel NLE** — media, preview, timeline, inspector |
| `davinci/` | 2 jpg | Cut page auto-edit UI (pro NLE) |
| `blender/` | 2 svg | VSE strip layout |
| `vscode/` | 5 png | Side bar, editor groups, palette patterns |
| `cursor/` | og | Agent-product positioning |
| `houdini/` | 3 png | **Node graph** density, subnets |
| `paraview/` | 0–6 | Pipeline browser + 3D view (when docs fetch ok) |
| `simscale/` | 2 | Cloud CAE project UI |
| `comsol/` | 6+ | **Model Builder** busbar workflow + GUI PNG |
| `figma-make/` | 10 | Figma Make / prompt-to-app marketing |
| `unity/` | 9 | UI Builder + **Timeline** manual images |
| `roblox/` | 9 | Studio + **Assistant** panels |
| `isaac/` | 3 | Isaac Sim viewport promos |
| `miro/` | up to 6 | Infinite board marketing |
| `benchling/` | 1 | Platform marketing — registry narrative |
| `clips/` | 20+ thumbs | Tutorial entry points per dimension |

**Re-run:** `./scripts/checkout-competitive-media.sh`

---

## 2. Cross-cutting lessons (from pixels)

### A. Layout (every dimension)

| Observation | Sources | Plan change |
|-------------|---------|-------------|
| **Center never < 50% width** | Godot, Roblox, CapCut, VS Code editor area | `ui_layout_agent_first`: enforce min viewport/canvas flex |
| **Left = structure, right = parameters** | UE, ParaView, CapCut, Unity UI Builder | Outliner + inspector mandatory in all workspaces |
| **Bottom = time** | CapCut, Blender VSE, UE sequencer | `studio.bottom_mode`: `timeline` \| `bench` \| `litl` |

### B. Cinematic workspace (CapCut + DaVinci + Blender + UE)

| Observation | Sources | Plan change |
|-------------|---------|-------------|
| **4 regions** map 1:1 to Li panels | CapCut webp series | **G3 Cinematic:** `MediaBin`, `SeqPreview`, `SeqTimeline`, `SeqInspector` |
| Export is **preset-first** (9:16, 1080p, 4K) | CapCut, Resolve marketing | `studio.publish_video` preset strip in Publish drawer |
| Scrub under preview, not hidden | All NLEs | Transport bar component in `li-seq` host |
| Blender VSE = strips horizontal | `vse-overview.svg` | `seq` track rows match NLE muscle memory |

### C. Engineering / scientific (ParaView + SimScale + COMSOL class)

| Observation | Sources | Plan change |
|-------------|---------|-------------|
| **Pipeline tree** = dataflow | ParaView docs, Houdini | Canvas `Source → Filter → Display` templates for `sim_scientific` |
| **Properties + Information tabs** | ParaView | Inspector tabs: **Params** \| **Validity** \| **Info** |
| Cloud run **status** prominent | SimScale banners | Bench panel: job state, oracle id, drift — not log-only |
| COMSOL needs **desktop capture** | og only | CAPTURE backlog P0 — Model Builder screenshot |

### D. Agent + commands (VS Code + Cursor + Houdini + ComfyUI class)

| Observation | Sources | Plan change |
|-------------|---------|-------------|
| **Palette + sidebar + editor** | VS Code hero, sidebyside | ⌘K + outliner + center + inspector |
| **Node color = state** | Houdini product shots | Canvas node: idle / running / pass / fail |
| Agent product OG ≠ IDE chrome | Cursor | Don't confuse marketing with Studio layout — steal VS Code structure |

### E. Creator / AM (Cura thumb + Prusa og)

| Observation | Sources | Plan change |
|-------------|---------|-------------|
| **Plater 3D + settings column** | Cura tutorial thumb | AM workspace: plater viewport + settings inspector |
| **3-click slice → preview → send** | Prusa/Cura class | `am_export` wizard steps fixed in UX RFC |

### F. Lab (Benchling platform image)

| Observation | Sources | Plan change |
|-------------|---------|-------------|
| **Registry + notebook** dual nav | Benchling Platform.png | `studio.adaptive`: Registry tab + Stage strip for LITL |

---

## 3. Plan improvements (concrete — v0.6)

### li-native-gui-plan.md

| Phase | Was | Now (from material) |
|-------|-----|---------------------|
| **G2 Studio shell** | Generic panels | **Dock IDs** match study: `dock.outliner`, `dock.viewport`, `dock.inspector`, `dock.bottom`, `dock.agent` |
| **G3 Cinematic** | Timeline stub | **4-panel NLE** per CapCut; presets 16:9 + 9:16 + 4K |
| **G3 Publish** | Hash only | Preset strip + progress bar + thumb preview frame |
| **G4 Canvas** | Nodes | Houdini-class **status color** on nodes; subnet = `canvas.group` |
| **G5 Scientific** | Field viz RFC | Inspector **Validity** tab; pipeline template nodes |
| **G6 AM** | Export RFC | 3-step wizard UI mock aligned to Cura plater |
| **G7 Agent** | Transcript | VS Code-style **Problems** panel bound to `lic diagnose` |

### unified-studio-ux-vision.md

- Add **§2.6 Material-backed layouts** pointer to this file.  
- Cinematic workspace wireframe references `capcut/desktop-ui-01.webp` locally.

### product-north-star.md

- Demo script: add **side-by-side** — CapCut export vs Li publish with **hash visible**.

---

## 4. Per-dimension: open locally

```bash
# Examples (from repo root)
xdg-open docs/game-dev/competitive-intel/media/local/capcut/desktop-ui-01.webp
xdg-open docs/game-dev/competitive-intel/media/local/godot/editor_intro_editor_empty.webp
xdg-open docs/game-dev/competitive-intel/media/local/vscode/hero.png
xdg-open docs/game-dev/competitive-intel/media/local/houdini/h20-nodes.png
```

| Dimension | Start with these files |
|-----------|------------------------|
| Game | `godot/editor_intro_3d_viewport.webp`, `roblox/editor-window.jpg` |
| Cinematic | `capcut/desktop-ui-*.webp`, `davinci/cut-automatic-ui.jpg`, `clips/davinci_resolve_18_ui-thumb.jpg` |
| Sci vis | `paraview/*`, `clips/paraview_intro-thumb.jpg` |
| CAE cloud | `simscale/product-tour.jpg` |
| Graph | `houdini/h20-nodes.png` |
| IDE | `vscode/hero.png`, `vscode/sidebyside.png` |
| AM | `clips/cura_5_interface-thumb.jpg` |
| Lab | `benchling/platform-ui.png` |

---

## 5. Still need manual capture (browser)

| Priority | Product | Target screenshot |
|----------|---------|-------------------|
| P0 | COMSOL | Model Builder + Study tree |
| P0 | Cura | Main window plater + preview slider |
| P1 | ParaView | Pipeline browser + color map (if auto-fetch empty) |
| P1 | Gazebo | Joint + scene view |
| P2 | Fusion | Timeline + simulate tab |

Save under `media/local/<name>/` per [CAPTURE.md](CAPTURE.md).

---

## 6. Next engineering sprint (UX-only, ordered)

1. **Wireframe** cinematic 4-panel from CapCut study → `specs/studio-ux-design-system-rfc.md`  
2. **Composable** `import_studio_layout_nle_smoke` with dock IDs  
3. **HTML demo** second page: `/cinematic.html` mirroring 4-panel  
4. **Bench panel** mock with fake validity row (scientific profile)  
5. Refresh **material-study-notes** after each `./scripts/checkout-competitive-media.sh` run

---

*Iterate this file when new folders appear in `manifest.json`.*
