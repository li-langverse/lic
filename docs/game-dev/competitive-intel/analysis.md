# Competitive analysis — synthesis for Li World Studio

**Inputs:** [media-catalog.md](media-catalog.md), [li-native-gui-plan.md](../plans/li-native-gui-plan.md) v0.4  
**Method:** Pattern extraction from official docs + keynotes (not hands-on benchmarking).

---

## 1. Executive summary

| Competitor | Strongest UX wedge | Weakness Li can exploit |
|------------|-------------------|-------------------------|
| **Unreal** | Sequencer + MRQ cinematic export; viewport-first | Opaque assets; agent-hostile graphs; heavy install |
| **Unity** | UI Toolkit separation (UXML/USS); Timeline | Split brain (IMGUI legacy); binding complexity |
| **Godot** | **Same scene tree** edit + run | Less AAA tooling; smaller creator economy |
| **Roblox** | **Creator UI tab**, Style Editor, UGC, Assistant | Not general-purpose engine; Luau not Li |
| **Blender** | VSE + 3D in one app | Not a game runtime; steep curve |
| **Figma** | **Infinite canvas**, sections, UI3 minimal chrome | Not simulation/game |
| **UEFN** | Creator cinematics device; template islands | Fortnite-only; device graph not diffable Li |

**Li position:** **Diffable Li** (`world`, `gui`, `scene`, `anim`, `seq`, `canvas`) + **agent manifest** + **`lic build` gate** + **infinite agentic canvas** — one language, no foreign UI stack.

---

## 2. Editor chrome patterns (what users expect)

### 2.1 Layout DNA (consensus)

```text
[Toolbar / tabs]     [Play] [Collaborate] [Agent?]
[Outliner | Hierarchy]  [VIEWPORT — largest]  [Inspector / Properties]
[Timeline / Sequencer — bottom, when in cinematic mode]
[Status / Output]
```

| Pattern | Who | Li plan mapping |
|---------|-----|-----------------|
| Viewport largest | All engines | `li-render` center; canvas embed for graph mode |
| Hierarchy left | UE, Unity, Godot, Roblox | Outliner = canvas node list + scene tree |
| Properties right | All | Inspector reflects Li types |
| Mode tabs (Home/Model/UI) | Roblox | `studio.workspace_*` |
| Dock / pin / float | Godot, Roblox | Li `gui` shell docking (native) |
| Command palette | VS Code, Cursor | `ui_cmd_*` (have) |

### 2.2 Screenshot checklist (capture locally)

See [CAPTURE.md](CAPTURE.md). Priority frames:

1. Default first-run layout  
2. Sequencer/Timeline open (bottom panel)  
3. UI authoring screen (UMG / UI Builder / Roblox UI tab)  
4. Play-in-editor (toolbar state change)  
5. Export/video dialog (MRQ / Blender render / publish)

---

## 3. Cinematic & video (product intros emphasis)

| Product | Intro narrative | UI mechanics | Li `li-seq` takeaway |
|---------|-----------------|--------------|---------------------|
| **UE5 keynote** | Lumen/Nanite/World Partition — **renderer** story | Sequencer secondary in docs | **Honest:** lead with measurable kernels; cinematic as **Li seq**, not fake Nanite |
| **UE Sequencer** | "Make movies in UE" | Tracks, camera cuts, MRQ | `seq.track_camera`, `seq.shot`, `studio.publish_video` |
| **Unity 6 keynote** | Faster render, multiplayer, AI | Timeline + **Time Ghost** demo | Deterministic replay + export hash |
| **UEFN Cinematic Device** | Creators make cutscenes | Device + level sequencer | `canvas` node `Sequence` → `seq/*.li` for creators |
| **Blender VSE** | Post-production | Strip retiming, audio | `seq` export path; optional audio v2 |

**Video export UX patterns to copy (Li):**

- Preset dropdown (1080p30, 4K60, preview quality)  
- Progress + frame checksum / repro ID  
- Output path + **PublishBundle** hash (already in `li-studio`)  
- "Render selected shots only" (subset compile)

**Avoid claiming:** MRQ-quality path tracing on day one.

---

## 4. In-game & creator UI

| Product | Creator UI model | Li `gui/*.li` takeaway |
|---------|------------------|------------------------|
| **Roblox** | UI tab insert + **Style Editor** | `gui.theme.li` + style tokens |
| **Unity UI Toolkit** | UXML + USS, UI Builder canvas | Same: Li source, visual editor emits Li |
| **UE UMG** | Widget blueprint | Prefer **Li only**, not graph |
| **Godot Control** | Scene tree nodes | `gui` widgets as nodes; link to `scene` |

**Roblox Assistant** = direct competitor to **agent dock** — transcript + actions; Li uses `lic diagnose` gate (stricter).

---

## 5. Infinite canvas (spatial authoring)

| Product | Canvas model | Li `canvas.li` takeaway |
|---------|--------------|-------------------------|
| **Figma** | Infinite 2D; sections; UI3 minimal UI | `gui.canvas` + sections as `canvas.region` |
| **ComfyUI** | Node graph execution | `AgentPlan` + `BenchRef` nodes with status color |
| **UE Blueprint** | Typed pins | `CanvasLinkKind` typed edges + `lic build` |
| **Blender** | Not primary | — |

**Differentiator:** Figma has no **sim/build gate**. Li canvas nodes compile to **`world.li` / `seq` / `gui`**.

---

## 6. 3D scene & animation

| Product | Scene | Animation | Li packages |
|---------|-------|-----------|-------------|
| **UE** | World Partition | Control Rig, Sequencer tracks | `li-scene`, `li-anim`, `li-seq` |
| **Unity** | Hierarchy + prefabs | Timeline animation tracks | same |
| **Godot** | Scene tree | AnimationPlayer | same + best **parity story** |
| **Roblox** | Workspace Explorer | Avatar tab animation tools | creator permissions |

**Intro videos hype renderer** (UE5, Unity 6). **Li intros should hype:** diffable world + agent patch + 60fps compositor bench validity.

---

## 7. Agent-first scorecard (qualitative)

| Capability | UE | Unity | Roblox | Li (target) |
|------------|-----|-------|--------|-------------|
| Machine-readable project | Low | Medium | Low | **High** (`*.li` + manifests) |
| Build gate before play | Compile | Compile | Runtime errors | **`lic build`** |
| Agent in product | Plugins | AI packages | **Assistant** | `studio-ai` + MCP |
| Spatial agent graph | No | No | No | **`canvas.li`** |
| Honest bench validity | External | External | No | **In-repo tier2** |

---

## 8. Recommendations → update plan v0.5

| Priority | Action |
|----------|--------|
| P0 | Add **media-catalog** links to onboarding doc for new contributors |
| P0 | Capture Roblox + UE Sequencer screenshots locally (see CAPTURE.md) |
| P1 | Studio **default workspace** = canvas (confirmed) |
| P1 | **Cinematic workspace** bottom timeline like UE (not hidden) |
| P1 | **Publish** preset UX like MRQ (presets only, honest scope) |
| P2 | **Style Editor**-class panel for `gui.theme` (Roblox parity for creators) |
| P2 | Compare reel: Li `seq` render vs `record-studio-demo.sh` HTML |
| P3 | Competitive slide: "Assistant vs `lic` gate" for investors |

---

## 9. What NOT to copy

| Anti-pattern | Source |
|--------------|--------|
| Binary-only UI assets | UE `.uasset` |
| IMGUI + UIToolkit split | Unity |
| Non-diffable device graphs | UEFN-only |
| Whiteboard-only canvas | Miro (no build) |
| Keynote renderer claims without benches | All keynotes — **Li must use validity.json** |

---

## 10. Li marketing narrative (evidence-based)

**Say:** "World Studio: infinite agentic canvas → diffable Li worlds, HUDs, and cinematics — one `lic build` gate."

**Show:** canvas graph → `seq` scrub → export WebM with hash → composable gate count.

**Don't say:** "Better than UE5" without `ue-baselines.csv`.

---

## Appendix: competitor one-pagers

- [by-competitor/unreal-engine.md](by-competitor/unreal-engine.md)  
- [by-competitor/unity.md](by-competitor/unity.md)  
- [by-competitor/godot.md](by-competitor/godot.md)  
- [by-competitor/roblox-studio.md](by-competitor/roblox-studio.md)  
- [by-competitor/blender.md](by-competitor/blender.md)  
- [by-competitor/figma.md](by-competitor/figma.md)  
- [by-competitor/fortnite-uefn.md](by-competitor/fortnite-uefn.md)
