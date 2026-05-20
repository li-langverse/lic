# Li native GUI — master plan (iterable)

| Field | Value |
|-------|--------|
| **Version** | 0.2 |
| **Status** | Draft — iterate in-repo |
| **Policy** | **Full Li only** — no Rust, C++, TypeScript, Slint, Svelte, or Electron on the GUI path |
| **Owners** | PH-UX, PH-GD, PH-GD-7, PH-AGENT |
| **Canonical** | This file is the single plan; other GUI plans are archived pointers |

**Changelog**

| Ver | Date | Change |
|-----|------|--------|
| 0.1 | 2026-05 | Initial: engine UX research, Studio + creator HUD |
| 0.2 | 2026-05 | **Li-only mandate**; removed Rust/web implementation paths |

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

**One GUI system, two surfaces** (both Li):

| Surface | Users | Host |
|---------|-------|------|
| **Studio chrome** | Developers, agents | `world-studio` binary (`lic build` of Li `studio` + `gui` + `ui`) |
| **Game UI** | Players, **creator-users** | `li-player` runtime |

Creators author **`gui/*.li`** (HUD, menus, inventories). Same tree runs in Studio preview and in published games.

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

### 2.2 In-game / user-created UI

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

---

## 4. Package architecture (all Li)

```text
packages/
  li-ui/          # Studio editor: ui_cmd_*, layouts, agent palette (existing)
  li-gui/         # NEW — schema, layout, paint IR, compositor, input (Li only)
  li-studio/      # Editor shell state, workspaces (existing)
  li-player/      # Client: load gui/, route input (extend)
  li-render/      # World viewport (3D/sim)
  li-gpu/         # Present / swapchain hooks (Li)

targets/
  world-studio/   # lic build entry: studio_main + full gui stack

my-game/
  world.li
  gui/
    hud.li
    theme.li
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

`li-ui` stays **editor-only** commands (`ui_cmd_*`). **`gui.cmd_*`** is **in-game** only.

### 4.2 Runtime flow (Li)

```text
lic build gui/hud.li  →  UiDocument IR + manifest JSON
        ↓
li-player tick:
  resolve bindings (Li) → layout (Li) → paint list (Li) → li-gpu present
        ↓
input → hit-test (Li) → gui.cmd / game sim
```

Studio preview uses the **same** `li-gui` code path inside `world-studio`.

---

## 5. Authoring model (`gui.li`)

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

---

## 6. Studio native shell (Li)

| Region | Li owner |
|--------|----------|
| Menu / toolbar | `li-studio` + `li-ui` |
| Outliner (entities + UI nodes) | `li-studio` + `li-gui` |
| Viewport | `li-render` / `li-gpu` |
| Inspector | `li-studio` (reflect Li types) |
| Command palette | `li-ui` (`ui_cmd_*`) |
| Agent dock | `li-studio-ai` + transcript types in `li-ui` |
| Status bar | `lic` gate + bench hooks |

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

Agents never drive pixels — only **Li source**.

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

---

## 10. Performance & honesty

| Claim | Allowed |
|-------|---------|
| Li compositor ms/frame on `render_frame_present` | Yes, with validity |
| “Faster than Unreal Slate” | No unless measured external baseline |
| Creator HUD in Li | Yes, with composable + manifest |

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

---

## 13. Related docs

| Doc | Role |
|-----|------|
| [specs/li-gui-schema-rfc.md](../specs/li-gui-schema-rfc.md) | Syntax + binding grammar |
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
