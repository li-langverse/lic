# Li native GUI — master plan (iterable)

| Field | Value |
|-------|--------|
| **Version** | 0.4 |
| **Status** | Draft — iterate in-repo |
| **Policy** | **Full Li only** — no Rust, C++, TypeScript, Slint, Svelte, or Electron on the GUI path |
| **Owners** | PH-UX, PH-GD, PH-GD-7, PH-AGENT |
| **Canonical** | This file is the single plan; other GUI plans are archived pointers |

**Changelog**

| Ver | Date | Change |
|-----|------|--------|
| 0.1 | 2026-05 | Initial: engine UX research, Studio + creator HUD |
| 0.2 | 2026-05 | **Li-only mandate**; removed Rust/web implementation paths |
| 0.3 | 2026-05 | **Infinite agentic canvas** — spatial Studio surface for agents + creators |
| 0.4 | 2026-05 | **Creative stack** — 3D scenes, animation, cinematics, video export (Li-only) |

---

## 0. Non‑negotiable: Li-only GUI

If we build a **native GUI**, the **entire product path** is Li:

| Layer | Language | Notes |
|-------|----------|--------|
| Schema (`UiDocument`, widgets, bindings) | **Li** | `packages/li-gui` |
| Layout, hit-test, focus, a11y order | **Li** | same package |
| Paint IR (draw lists, clips, text glyphs) | **Li** | consumed by `li-render` / `li-gpu` |
| Studio chrome + UI Editor logic | **Li** | `li-studio` + `li-ui` |
| Shipped player HUD | **Li** | `li-player` loads `gui/*.li` |
| Build / proof | **`lic`** | same gate as `world.li` |
| Agents | **Li + manifest** | patch `gui.li`; no TS/React source of truth |

**Forbidden on GUI path:** new Rust crates, Slint, Tauri, Svelte, React, UXML, separate C UI toolkit.

**Allowed:** `lic` compiling Li → native binary; existing **world** timed kernels stay as today (do not expand foreign code for GUI). Viewport may use **`li-gpu` / `li-render`** (Li packages), not a second foreign UI stack.

**Iterate this doc** — edit sections, bump version table above, open PR.

---

## 1. Goal

**One creative authoring system in Li** — GUI + spatial canvas + **3D scenes + animation + cinematics + video** — all diffable, agent-gated, **no foreign authoring languages**.

### 1.1 Surfaces (all Li)

**Four user-facing surfaces** plus shared creative core:

| Surface | Users | Host |
|---------|-------|------|
| **Studio chrome** | Developers, agents | `world-studio` — panels, palette, inspector |
| **Infinite agentic canvas** | Developers, agents, creators | `world-studio` — spatial graph of worlds, sims, UI, notes |
| **Game UI** | Players, **creator-users** | `li-player` — `gui/*.li` HUD (screen-space, not infinite canvas) |
| **Cinematic / video** | Creators, marketing, agents | `seq/*.li` timelines → **MP4/WebM** via `studio.publish` |

Creators author:

| Artifact | Purpose |
|----------|---------|
| `gui/*.li` | HUD, menus |
| `canvas/*.li` | Spatial graph (worlds, sequences, links) |
| `scene/*.li` or `world.li` + scene | **3D placement**, transforms, hierarchy |
| `anim/*.li` | Keyframes, clips, blend trees (stubs → full) |
| `seq/*.li` | **Cinematic timeline** — shots, cameras, cuts, audio marks |
| `assets/*` | glTF meshes, textures (via `li-assets`) |

**Infinite canvas** = default Studio workspace — nodes include **Sequence**, **Shot**, **Camera**, **AnimationClip**, not only World/GuiScreen.

**Creative parity target (honest):** not day-one UE Sequencer + Movie Render Queue — phased **Li seq + replay + export** with validity on deterministic frames.

---

## 2. What we learn from other engines (UX only)

We **do not** copy their implementation language — only patterns.

### 2.1 Editor chrome

| Source | Steal | Avoid |
|--------|-------|-------|
| **Unreal** | Viewport-first; Outliner + Details; Content Browser; Play toolbar | Dense clutter |
| **Unity UIToolkit** | Markup + theme tokens in git | IMGUI split-brain |
| **Godot** | Same tree in editor and runtime | — |
| **Blender** | Workspace presets (game / sim / drug) | — |
| **Cursor** | ⌘K palette, agent transcript, build gate | — |
| **Figma / Miro / tldraw** | Infinite 2D canvas; frames; connectors | Pixel pushing not needed — **spatial graph + links** |
| **Unreal Blueprint** | Node graph editor | Typed pins; compile gate — **Li canvas → `lic build`** |
| **ComfyUI / n8n** | Agent workflows on canvas | **Agent cards** with status (pending / green / failed) |

### 2.3 Cinematics, animation, video (UX only)

| Source | Steal | Avoid |
|--------|-------|-------|
| **Unreal Sequencer** | Timeline, shots, camera cuts, spawnables, take recorder | Opaque take binary |
| **Unity Timeline** | Tracks per object; animation / activation / audio | Mixing with unrelated prefab-only workflow |
| **Blender** | Scene + timeline + VSE | Becoming a full DCC — we **author in Li**, preview in Studio |
| **Godot AnimationPlayer** | Named clips, blend | — |
| **After Effects / Resolve** (class) | Comp layers, export presets | Proprietary project formats — **export from Li manifest** |
| **Roblox / Fortnite Creative** | User-made experiences + thumbnails | — |

**Li takeaway — creative:**

1. **3D scene** = `li-scene` graph synced with `world` / physics.  
2. **Animation** = `anim/*.li` curves bound to `SceneNode` paths.  
3. **Cinematic** = `seq/*.li` timeline drives camera + spawns + clip playback.  
4. **Video** = deterministic **offline render** or real-time capture → `studio.publish` bundle (repro hash).  
5. **Canvas** shows Sequence nodes linked to World + Export nodes.

### 2.4 In-game / user-created UI

| Source | Steal | Avoid |
|--------|-------|-------|
| **UMG / UI Toolkit / Godot Control** | Retained tree, bindings, anchors | Opaque binary widgets |
| **Roblox** | Creators ship HUDs; sandboxed actions | Unsafe scripting |
| **Dear ImGui** | — | Player-facing UI (dev overlay only, later, in Li) |

---

## 3. Design principles

| # | Principle |
|---|-----------|
| P1 | One `UiDocument`, two hosts (Studio + player) |
| P2 | **Li authors truth** — renderer executes Li paint IR |
| P3 | Agent-stable `widget_id`, `gui.cmd`, exported manifest |
| P4 | `lic build` before play/publish |
| P5 | 60 fps: layout + compositor budgets (see `render_frame_present` bench) |
| P6 | Studio primary flows ≤ 3 clicks |
| P7 | Visual editor **emits Li** (never a parallel format) |
| P8 | Diffable `gui/` + `theme.li` in git |
| P9 | **Canvas is Li** — `canvas.li` / `CanvasDocument`; not a proprietary binary scene |
| P10 | **Infinite extent** — virtual bounds; tile paint + cull; pan/zoom @ 60 fps |
| P11 | **Agents place nodes** — `canvas_node_id`, `canvas_link_id`; manifest for MCP |
| P12 | **Canvas → build** — subgraph selection compiles to `world.li` / `gui/` / `sim` profile |
| P13 | **Creative is Li** — `scene`, `anim`, `seq` files; not `.uasset` / `.blend` only |
| P14 | **Deterministic takes** — same `seq` + seed → same frame hash (replay for video) |
| P15 | **Agents edit timelines** — `seq_track_id`, `shot_id` in manifest |
| P16 | **Creators export video** — preset + `lic build` + publish bundle |

---

## 4. Package architecture (all Li)

```text
packages/
  li-ui/          # Studio editor: ui_cmd_*, layouts, agent palette (existing)
  li-gui/         # NEW — schema, layout, paint IR, compositor, input (Li only)
  li-studio/      # Editor shell state, workspaces (existing)
  li-player/      # Client: load gui/, route input (extend)
  li-render/      # World + cinematic viewport (3D/sim)
  li-gpu/         # Present / swapchain / offline frame export (Li)
  li-scene/       # Scene graph, Transform3, EntityId (extend)
  li-assets/      # glTF, textures, audio refs (extend)
  li-anim/        # NEW — clips, curves, skeletal stub (Li only)
  li-seq/         # NEW — cinematic timeline, shots, cameras (Li only)

targets/
  world-studio/   # lic build entry: studio_main + full gui stack

my-game/
  world.li
  scene/
    main.li
  anim/
    hero_walk.li
  seq/
    intro_cinematic.li
  gui/
    hud.li
    theme.li
  assets/
    hero.gltf
  publish/
    exports/          # generated MP4/WebM + manifest hash
```

**No `li-gui-native` Rust crate.** The name **`li-gui`** is the native GUI package in Li.

### 4.1 `li-gui` module breakdown (Li)

| Module | Responsibility |
|--------|----------------|
| `gui.document` | `UiDocument`, widget tree, versioning |
| `gui.widget` | Panel, Label, Button, Progress, Image, Grid, Scroll |
| `gui.theme` | Tokens (color, spacing, type scale) |
| `gui.bind` | Typed paths → `world` / `player` fields |
| `gui.layout` | Constraints, anchors, measure, arrange |
| `gui.paint` | Draw list: rect, text, image, clip |
| `gui.input` | Hit-test, focus, key/pointer events |
| `gui.cmd` | In-game commands (`gui.cmd_jump`, …) |
| `gui.compositor` | Layer game UI + optional dev overlay |
| `gui.canvas` | **Infinite agentic canvas** — nodes, links, camera, tiles |
| `gui.canvas.node` | World, SimField, GuiScreen, AgentPlan, Note, BenchRef, … |
| `gui.canvas.link` | Typed edges (spawns, binds, replicates, documents) |
| `seq.timeline` | Tracks: camera, transform, spawn, anim clip, audio, event |
| `seq.shot` | Time range, camera rig, world subset |
| `anim.clip` | Keyframes / curve channels → `SceneNode` paths |
| `anim.playback` | Sample clip at `t` → transform / morph stub |

`li-ui` stays **editor-only** commands (`ui_cmd_*`). **`gui.cmd_*`** is **in-game** only.  
**`canvas.*`** is **Studio-only** (never shipped in player HUD).

### 4.3 Infinite agentic canvas (design)

**What it is:** A **2D world space** (Li coords, unbounded) where nodes are **first-class artifacts** and agents **read/write the graph** before touching pixels.

```text
┌────────────────────────────────────────────────────────────────────────┐
│  Studio toolbar · ⌘K · agent transcript                                 │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│     ┌──────────┐      spawns      ┌─────────────┐                      │
│     │ world.li │ ───────────────► │ GameWorld   │──┐                   │
│     │  node    │                  │  preview    │  │ replicates        │
│     └──────────┘                  └─────────────┘  ▼                   │
│           │                              ┌──────────────┐               │
│           │ documents                    │ gui/hud.li   │               │
│           └────────────────────────────► │  screen node │               │
│                                            └──────────────┘               │
│     ┌────────────┐   bench ref   ┌────────────────┐                    │
│     │ AgentPlan    │ ────────────► │ sim_physics    │                    │
│     │  (MCP card)  │               │  frame (tag)   │                    │
│     └────────────┘               └────────────────┘                    │
│              ∞ pan / zoom (camera transform in Li)                      │
└────────────────────────────────────────────────────────────────────────┘
```

**Node kinds (v1):**

| `CanvasNodeKind` | Binds to | On-canvas preview |
|------------------|----------|-------------------|
| `World` | `world.li` path | Mini viewport / entity count |
| `GuiScreen` | `gui/*.li` | Thumbnail frame |
| `SimField` | `sim` / scientific profile | Heatmap stub |
| `AgentPlan` | transcript + patch id | Status chip (idle/build/ok/fail) |
| `Note` | markdown hash | Sticky note |
| `BenchRef` | benchmark id | Last median ms |
| `Realm` | MMO shard metadata | Shard id + tick budget |
| `Sequence` | `seq/*.li` path | Timeline strip preview |
| `Shot` | Sub-range of sequence | Thumbnail + duration |
| `Camera` | Camera rig / cut | Frustum preview |
| `AnimationClip` | `anim/*.li` | Clip name + duration |
| `VideoExport` | Publish preset | Last export hash + resolution |
| `Scene3D` | `scene/*.li` | Node count + root transform |

**Link kinds (v1):** `Spawns`, `Binds`, `Replicates`, `Documents`, `DependsOn`, `AgentEdited`, **`Plays`**, **`CutsTo`**, **`Animates`**, **`Renders`**.

### 4.5 Creative pipeline (3D · animation · cinematics · video)

```text
assets (glTF) ──► li-scene ──► world + physics
                      │
anim/*.li (clips) ────┤
                      ▼
seq/*.li (timeline) ──► sim replay @ fixed dt ──► li-render frames
                      │
                      ▼
              studio.publish → video (WebM/MP4) + PublishBundle hash
```

| Stage | Li owner | Agent / creator |
|-------|----------|-----------------|
| **Layout 3D** | `li-scene` + viewport gizmos | Place nodes; canvas `Scene3D` node |
| **Animate** | `li-anim` | Keyframe editor; `anim/*.li` |
| **Direct** | `li-seq` | Timeline UI (Li); shots + camera cuts |
| **Preview** | `li-render` + `li-gpu` | Scrub timeline @ 30/60 fps |
| **Export** | `studio.publish` + `li-gpu` encode | Preset: 1080p30, 4K60; repro manifest |

**In-game vs Studio:** Players see **results** (cinematic playback in-game via `seq` player mode). **Authoring** is Studio (+ creator mode later). User-generated **machinima**: creator links `seq` + `world` on canvas → export → share `publish` bundle.

**Video export (Li-only path):**

- `seq_render_frame(seq, t)` → render target (Li → `li-render`)  
- `seq_encode_video(frames, preset)` → container (Li package `li-gpu` or `studio.publish` codec stub)  
- **No After Effects project** — optional **import manifest** only  

**Animation v1:**

- Transform channels: `px, py, pz, qx, qy, qz, qw` on `SceneNode` path  
- Float curves: piecewise linear → `decreases` on segment count  
- **Skeletal / skinned mesh:** Phase G7+ (bind to `li-assets`)

**Cinematic v1:**

- Tracks: `Camera`, `Transform`, `Spawn`, `AnimClip`, `Event`  
- Shots: `[t0, t1]` + camera override + sub-world flag  
- **Cut** events: hard camera switch  

**3D scene v1:**

- Extend existing `li-scene` (`SceneNode`, `Transform3`)  
- Sync hooks: `scene_sync_from_physics` (already stubbed)  
- **Not** replacing `li-render` — scene feeds render

### 4.6 Studio workspaces (creative modes)

| Workspace | Primary view | Li files |
|-----------|--------------|----------|
| **Canvas** (default) | Infinite graph | `canvas.li` |
| **Scene** | 3D viewport + gizmos | `scene/*.li`, `world.li` |
| **Animate** | Dope sheet / curve editor | `anim/*.li` |
| **Cinematic** | Timeline (Sequencer-class) | `seq/*.li` |
| **UI** | Screen HUD editor | `gui/*.li` |
| **Publish** | Export queue (video, figures, bundles) | `studio.publish` |

Switch via `ui_layout_*` / `studio.workspace_*` — same **Li-only** chrome.

**Camera:** `CanvasCamera { pan_x, pan_y, zoom }` — Li state; gestures → `canvas.cmd_pan`, `canvas.cmd_zoom`.

**Infinite mechanics (Li, no foreign engine):**

- **Virtual grid** — `int64` world coords; no hard max size  
- **Tile index** — `canvas.tile_key(tx, ty)` for paint cull + hit-test  
- **Level-of-detail** — zoomed out: icons only; zoomed in: preview ports  
- **Spatial index** — hash map tile → node ids (Li `CanvasIndex`)

**Agentic rules:**

1. Agent adds node → must set `canvas_node_id` + `source_path` (`world.li`, etc.)  
2. Agent adds link → `lic build` validates typed endpoints (no `World → BenchRef` nonsense unless allowed)  
3. Agent “apply patch” → updates **Li file** + **canvas node status** in one transcript line  
4. MCP tools: `canvas_add_node`, `canvas_link`, `canvas_focus`, `canvas_compile_selection`

**Not the same as game UI:** Canvas is **authoring**; `gui/*.li` is **player screen-space**. A `GuiScreen` **node** on canvas **opens** the UI editor for that file.

### 4.4 Runtime flow (Li)

```text
lic build gui/hud.li  →  UiDocument IR + manifest JSON
        ↓
li-player tick:
  resolve bindings (Li) → layout (Li) → paint list (Li) → li-gpu present
        ↓
input → hit-test (Li) → gui.cmd / game sim
```

Studio preview uses the **same** `li-gui` code path inside `world-studio`.

**Canvas:**

```text
canvas/world.canvas.li  →  CanvasDocument IR + canvas.manifest.json
        ↓
Studio: camera + tiles → paint links/nodes → optional embed li-render preview per World node
        ↓
canvas_compile_selection() → triggers lic build on referenced paths only
```

---

## 5. Authoring models

### 5.1 Screen UI (`gui.li`)

Illustrative API (syntax RFC before implementation):

```li
import gui

def hud_main() -> gui.Document
=
  return gui.doc(
    gui.panel(id=1, anchor=gui.top_right(), width=gui.dp(200), height=gui.dp(80)),
    gui.progress(id=2, bind=gui.float_path("player.health"), min=0.0, max=100.0),
    gui.button(id=3, label="Jump", on_press=gui.cmd("player.jump")))
```

| Artifact | Purpose |
|----------|---------|
| `gui/*.li` | Source |
| `gui.manifest.json` | Agent/MCP index (generated by `lic`) |
| `theme.li` | Shared tokens |

**Bindings** invalid at compile time → `lic build` fails (like broken `world.li`).

### 5.2 Infinite canvas (`canvas.li`)

Illustrative API:

```li
import gui.canvas

def studio_world_graph() -> gui.canvas.Document
=
  var cam: gui.canvas.Camera = gui.canvas.camera_default()
  var n_world: int = gui.canvas.node_world(id=10, path="world.li", at=gui.canvas.vec(0, 0))
  var n_hud: int = gui.canvas.node_gui_screen(id=11, path="gui/hud.li", at=gui.canvas.vec(480, 0))
  gui.canvas.link_binds(from=n_world, to=n_hud, id=100)
  return gui.canvas.doc(camera=cam, nodes=gui.canvas.node_set(n_world, n_hud))
```

| Artifact | Purpose |
|----------|---------|
| `canvas/*.li` or `world.canvas.li` | Spatial graph source |
| `canvas.manifest.json` | Agent index: nodes, links, bounds, selection |
| `canvas.selection` | Ephemeral — which subgraph to build/play |

**Workspace default:** new Studio project opens **canvas view**; classic panels dock on edges (outliner = filtered list view of canvas nodes).

### 5.3 Scene (`scene.li`)

```li
import scene

def main_scene() -> scene.Scene
=
  var s: scene.Scene = scene.scene_new()
  var root: scene.SceneNode = scene.node_with_transform(
      scene.entity_id_new(1), scene.transform_identity())
  scene.scene_attach_node(s, root)
  return s
```

### 5.4 Animation (`anim/*.li`)

Illustrative:

```li
import anim

def hero_walk_clip() -> anim.Clip
=
  return anim.clip(
    anim.channel_transform(scene_path="hero", keyframes=anim.keys_walk_stub()))
```

### 5.5 Cinematic (`seq/*.li`)

Illustrative:

```li
import seq

def intro_cinematic() -> seq.Timeline
=
  return seq.timeline(
    fps=60,
    duration_sec=12,
    seq.track_camera(seq.shot_wide(0.0, 4.0)),
    seq.track_anim(seq.play_clip("anim/hero_walk.li", at=2.0)),
    seq.track_event(seq.cut_camera("cam_close", at=4.0)))
```

| Artifact | Purpose |
|----------|---------|
| `seq/*.li` | Timeline source |
| `seq.manifest.json` | Agent index: shots, tracks, cuts |
| `publish/video.toml` | Resolution, codec, output path |

---

## 6. Studio native shell (Li)

| Region | Li owner |
|--------|----------|
| **Infinite canvas** (center) | `li-gui` **`gui.canvas`** — primary workspace |
| Menu / toolbar | `li-studio` + `li-ui` |
| Outliner | Projection of **canvas nodes** + entity tree for selected World |
| Embedded viewport | `li-render` inside **World** / **SimField** canvas nodes |
| Inspector | `li-studio` — node props + Li file fields |
| Command palette | `li-ui` (`ui_cmd_*`) + `canvas.cmd_*` |
| Agent dock | `li-studio-ai` + transcript; **pins to canvas selection** |
| **Timeline** (Cinematic workspace) | `li-seq` + scrubber UI in Li |
| **Curve / dope sheet** (Animate) | `li-anim` |
| Status bar | `lic` gate + bench + canvas tile + **seq timecode** |

Entry binary: extend `packages/li-studio/src/studio_main.li` → real shell when compositor ready (today: gate stub).

---

## 7. User-created GUIs (creators)

| Phase | Capability |
|-------|------------|
| **G0** | Write `gui.li` by hand; preview in Studio |
| **G1** | Li UI Editor: manipulators emit `gui.li` |
| **G2** | Property picker for bindings |
| **G3** | In-game creator mode (realm permission) |
| **G4** | Share gui packages (reviewed manifest) |

**Sandbox:** `gui.cmd` whitelist only; server validates in MMO (see `li-world` replication).

---

## 8. Agent-first

| Tool / artifact | Action |
|-----------------|--------|
| `gui.li` | Patch target |
| `gui.manifest.json` | Read widget ids / cmds |
| `ui_cmd_*` | Studio chrome only |
| `lic build` | Gate |
| MCP `gui_scaffold` (future) | NL → Li HUD |
| MCP `canvas_*` (future) | NL → spatial graph |
| MCP `seq_*` (future) | “Add 5s camera pan” → `seq/*.li` |
| `canvas.manifest.json` | Spatial index for agents |
| `seq.manifest.json` | Timeline index for agents |

Agents never drive pixels — only **Li source** + **canvas graph** + **seq/anim/scene** files (camera snaps are `canvas.cmd_focus`, not mouse coords).

---

## 9. Implementation phases (Li-only)

### Phase G0 — Schema & proof (first code)

- [ ] `packages/li-gui` scaffold (`import gui`, `Document`, widgets stub)
- [ ] Extend `li-ui` version / cross-refs
- [ ] Composable: `import_gui_document_smoke.li`
- [ ] `scripts/gen-gui-manifest.li` or harness script reading Li constants
- [ ] RFC: finalize syntax in `specs/li-gui-schema-rfc.md`

### Phase G1 — Layout + paint IR (Li)

- [ ] `gui.layout` measure/arrange smokes
- [ ] `gui.paint` draw list + checksum smoke
- [ ] Tie to `render_frame_present` bench (Li/C kernel policy unchanged for bench only if already there — **no new C for GUI**)

### Phase G2 — Compositor + player

- [ ] `li-gpu` present path consumes paint IR
- [ ] `li-player` loads `gui/` in client loop
- [ ] Input hit-test smokes

### Phase G3 — Studio shell

- [ ] `world-studio` target: outliner, inspector, palette in **Li** (not HTML demo)
- [ ] Deprecate `deploy/studio-demo` as canonical (keep as screenshot legacy optional)

### Phase G4 — Creator UX

- [ ] Visual editor writes `gui.li`
- [ ] Creator mode + MMO permissions

### Phase G5 — Infinite agentic canvas

- [ ] `gui.canvas` types: `Document`, `Node`, `Link`, `Camera`, `TileIndex`
- [ ] `canvas.li` parse + `lic build` + composable `import_canvas_document_smoke.li`
- [ ] Pan/zoom + tile cull paint in Li (`gui.canvas.paint`)
- [ ] Node previews: World → embed `li-render`; GuiScreen → mini `gui` layout
- [ ] Agent cards (`AgentPlan` node) with diagnose/build status colors
- [ ] `canvas_compile_selection` → `lic build` referenced paths
- [ ] MCP: `canvas_add_node`, `canvas_link`, `canvas_focus`
- [ ] Bench: `canvas_frame_pan_zoom` tier-2 (Li-only timing of tile paint, optional)

### Phase G6 — 3D scene + animation (Li)

- [ ] Extend `li-scene`: node paths, parent/child, gizmo hooks (Li)
- [ ] `packages/li-anim`: `Clip`, `Channel`, `Sample` + composable smoke
- [ ] Animate workspace: curve editor (Li paint, not foreign toolkit)
- [ ] Canvas nodes: `Scene3D`, `AnimationClip`
- [ ] Link `anim` → `SceneNode` paths; `lic build` validates paths

### Phase G7 — Cinematics + video export (Li)

- [ ] `packages/li-seq`: `Timeline`, `Track`, `Shot`, `CameraCut`
- [ ] Cinematic workspace: timeline UI (Li); scrub → `li-render`
- [ ] `seq_playback_at(t)` deterministic replay (sim + world + anim)
- [ ] `studio.publish` video preset: 1080p WebM/MP4 + **PublishBundle** hash
- [ ] Replace headless Chrome demo reel with **Li seq render** path (see `record-studio-demo.sh` successor)
- [ ] Canvas nodes: `Sequence`, `Shot`, `Camera`, `VideoExport`
- [ ] MCP: `seq_add_shot`, `seq_add_track`, `publish_render_video`
- [ ] Bench (optional): `seq_frame_render` tier-2 wall time per frame

### Phase G8 — Creator creative (in-game + UGC)

- [ ] Creator mode: place props + simple anim (permissions)
- [ ] User-shared `seq` + `publish` bundles on realm (MMO)
- [ ] Machinima template spin-ups on canvas

---

## 10. Performance & honesty

| Claim | Allowed |
|-------|---------|
| Li compositor ms/frame on `render_frame_present` | Yes, with validity |
| “Faster than Unreal Slate” | No unless measured external baseline |
| Creator HUD in Li | Yes, with composable + manifest |
| “UE Sequencer parity” | No without measured baseline + feature checklist |
| Deterministic cinematic frame | Yes, with `seq` replay hash + validity |
| User-exported video | Yes, with publish manifest + preset recorded |

---

## 11. Web / WASM / other langs

| Path | Status |
|------|--------|
| Svelte / Tauri / Next shell | **Archived** — not part of native GUI plan |
| WASM preview | Optional **later**; same `gui.manifest.json`, still authored in Li |
| Benchmark C world kernels | Unchanged; **not** GUI |

See archived note: [li-gui-cross-platform-plan.md](li-gui-cross-platform-plan.md).

---

## 12. Open questions (edit as we iterate)

- [ ] Single package `li-gui` vs split `li-gui` + `li-gui-studio`?
- [ ] Embed GUI nodes in `world.li` or only `gui/*.li`?
- [ ] Font: bitmap stub first vs Li font atlas in `li-assets`?
- [ ] Window creation: which `lic` target triple for `world-studio`? (`targets/manifest.toml`)
- [ ] Dev overlay (ImGui-class) in Li for profilers — yes/no?
- [ ] Canvas file: one `world.canvas.li` per project vs `canvas/*.li` graphs?
- [ ] Max nodes before LOD-only (performance)? default 10k?
- [ ] Creators: read-only canvas on published realms or full edit?
- [ ] Video codec path: Li-only encoder stub vs platform encode API (still no FFmpeg **authoring** — export driver TBD in Li)?
- [ ] Audio tracks in `seq` v1 or v2?
- [ ] Skeletal animation: which `li-assets` skin format first?

---

## 13. Related docs

| Doc | Role |
|-----|------|
| [specs/li-gui-schema-rfc.md](../specs/li-gui-schema-rfc.md) | Syntax + binding grammar |
| [specs/li-canvas-agentic-rfc.md](../specs/li-canvas-agentic-rfc.md) | Infinite canvas nodes + links |
| [specs/li-creative-cinematic-rfc.md](../specs/li-creative-cinematic-rfc.md) | Scene, anim, seq, video export |
| [specs/studio-ux-design-system-rfc.md](../specs/studio-ux-design-system-rfc.md) | PH-UX phases |
| [agent-first-gui-research.md](../agent-first-gui-research.md) | SOTA research |
| [world-studio-vision.md](../world-studio-vision.md) | Program rollup |

---

## 14. How to iterate this plan

1. Edit **this file** on a feature branch.  
2. Bump **Version** + row in **Changelog**.  
3. Check open questions §12; move decisions into §3–§9.  
4. When G0 starts, link PRs in changelog row.

**Do not** add implementation languages to this plan without explicit program approval (violates §0).
