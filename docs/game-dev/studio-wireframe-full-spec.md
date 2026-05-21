# World Studio wireframe — full implementation spec

**Status:** Canonical mapping from HTML prototype → native `li-studio` / `li-ui`  
**Prototype:** `lic/deploy/studio-demo/`  
**UX audit:** [studio-wireframe-ux-audit.md](studio-wireframe-ux-audit.md)  
**Vision:** [unified-studio-ux-vision.md](unified-studio-ux-vision.md)

This document is the **build contract** for UX-2+. The HTML wireframe is **not** shipped product; it defines surfaces, IDs, and interactions agents and humans share.

---

## 1. Shell layout (one grid)

```text
┌─ Topbar: brand · gate chip · validity · theme · ⌘K · Play ─────────────────┐
├──────────┬──────────────────────────────────────────────┬──────────────────┤
│ Scene    │ [Viewport | Code | Canvas]  + profile select │ Agent            │
│ Assets   │  PRIMARY SURFACE                             │ Inspector        │
├──────────┴──────────────────────────────────────────────┴──────────────────┤
│ Problems | Terminal | Output | Timeline (profile-adaptive)                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

| Wireframe file | Native owner (target) |
|----------------|----------------------|
| `index.html` + `studio-shell.css` | `li-studio` window layout |
| `studio.css` + `studio-themes.js` | `li-ui` theme tokens / `UiThemeProfile` |
| `studio-editor.js` | `li-studio-editor` (wraps editor widget) |
| `studio-panels.js` | `li-studio` panels + `lic` JSON feeds |
| `studio-files.js` | Workspace VFS sample data |
| `studio.js` | Viewport tick + command dispatch demo |

---

## 2. Surface inventory

### 2.1 Code editor (user custom creations)

**Wireframe:** Center tab **Code** · CodeMirror · multi-tab `.li` / `studio.toml`.

| Feature | Wireframe | Native (UX-2) |
|---------|-----------|---------------|
| Multi-file tabs | `#editor-file-tabs` | `studio.editor_open(path)` |
| Syntax | Python mode stand-in for Li | `lic` LSP / tree-sitter Li |
| New file | `+` tab | `studio.new_file("packages/…")` |
| Save / build | ⌘S → `ui_cmd_3` | `lic build` on save or explicit |
| Dirty indicator | `•` on tab | `EditorBuffer.dirty` |
| Jump from Problems | click row → line | `lic diagnose` → `editor.reveal(line)` |

**Sample paths (virtual FS in `studio-files.js`):**

- `world.li` — scene root  
- `physics/custom_gravity.li` — user physics law  
- `packages/game/rocket_logic.li` — **user gameplay code**  
- `gui/hud.li` — in-game HUD source  
- `studio.toml` — project + bench config  

### 2.2 Inline diff (Cursor parity)

**Wireframe:** `#diff-panel` under editor; hunks from `StudioFiles.PATCH_DIFF`.

| Action | `ui_cmd_*` | Native |
|--------|------------|--------|
| Show diff | 4 (Apply patch flow) | `studio_ai_preview_patch(patch_id)` |
| Apply | `#diff-apply` | `studio_ai_apply_if_clean_stub` after `lic_gate` |
| Dismiss | `#diff-close` | discard patch buffer |

### 2.3 Problems panel (VS Code parity)

**Wireframe:** Bottom **Problems** · rows from `StudioFiles.PROBLEMS`.

| Field | Maps to |
|-------|---------|
| `severity` | `lic diagnose` level |
| `code` | `E0303`, `W1201`, … |
| `file` / `line` | jump target |
| Click row | `StudioEditor.openFile(file, line)` |

Native: `ui_panel_problems` + subscribe to `lic check --format=json`.

### 2.4 Inspector (UE / Unity parity)

**Wireframe:** Right rail **Inspector** · `#inspector-form` from `INSPECTOR_SCHEMA`.

| Control | Li type |
|---------|---------|
| vec3 | `float` × 3 + unit |
| float | slider + spin |
| enum | dropdown bound to manifest |
| bool | toggle |

Selection: outliner click → `studio_inspector_bind(entity_id)`.

### 2.5 Content browser (UE Assets)

**Wireframe:** Left **Assets** tab · `#assets-list`.

Native: `li-assets` index + import drag-drop; thumbnails via `li-render` preview.

### 2.6 Viewport + gizmo stub

**Wireframe:** Canvas 2D demos + `#viewport-gizmo` overlay.

Native: `li-render` present + `li-scene` pick buffer; gizmos = `ui_gizmo_translate` etc.

### 2.7 Agent dock (Li differentiator)

**Wireframe:** Transcript · plan cards · Apply/Reject · `@file` chip · `/build` hints.

| Element | API |
|---------|-----|
| Transcript roles | `ui_transcript_append(role, …)` |
| Plan | `studio_ai_plan_steps[]` |
| Gate inline | `lic_gate` string from build |
| @file | `studio_context_attach(path)` |

### 2.8 Command palette

**Wireframe:** ⌘K · `COMMANDS[]` in `studio.js` (ids 1–10).

Native: same IDs in `packages/ui/src/lib.li` (`ui_cmd_*`) + MCP export table.

### 2.9 Bottom panels

| Tab | Wireframe content | Profile default |
|-----|-------------------|-----------------|
| Problems | diagnose list | all |
| Terminal | `lic build`, patch log | all |
| Output | bench / check JSON | sim |
| Timeline | Sequencer or LITL strip | game / drug |

`StudioPanels.showTimelineForDemo` switches strip by workspace.

### 2.10 Canvas (Figma / Comfy parity)

**Wireframe:** Center **Canvas** tab · stub nodes Plan → world.li → lic build.

Native: [li-canvas-agentic-rfc.md](specs/li-canvas-agentic-rfc.md) · compile selection to `*.li`.

### 2.11 Themes

**Wireframe:** aurora / ember / slate + custom JSON (`studio-themes.js`).

Native: `studio.toml [theme]` + `UiThemeProfile` + optional user JSON path.

### 2.12 Focus mode

**Wireframe:** Topbar **Focus** · `body.studio-focus` hides rails.

Native: `ui_layout_focus()` collapses docks; viewport/canvas maximized.

---

## 3. Command registry (wireframe ids)

| `ui_cmd_id` | Label | Wireframe behavior |
|-------------|-------|-------------------|
| 1 | Play | `setDemo("play")` + gate transcript |
| 2 | Pause | stub |
| 3 | Build | PASS chip + transcript |
| 4 | Apply patch | open diff + agent actions |
| 5 | Open world.li | editor tab `world.li` |
| 6 | Open Code | center panel Code |
| 7 | Problems | bottom tab |
| 8 | Focus mode | toggle rails |
| 9 | New .li | new tab under `packages/game/` |
| 10 | Bench tier-2 | output log line |

Extend in `packages/ui` when native — **do not renumber** without MCP version bump.

---

## 4. Li API gaps (prototype → implement)

Already stubbed in `packages/ui/src/lib.li`:

- `ui_layout_agent_first`
- `ui_cmd_*` (1–5; extend to 10)
- `ui_agent_action_new`, `ui_transcript_append`

**Add for UX-2:**

```text
ui_panel_problems()
ui_panel_editor()
ui_panel_terminal()
studio_editor_open(path: string) -> int
studio_editor_apply_patch(patch_id: int) -> int  # requires lic_gate
studio_inspector_bind(entity_hash: int) -> unit
studio_theme_load_json(path: string) -> int
```

---

## 5. Implementation phases (from wireframe)

| Phase | Deliverable | Wireframe proof |
|-------|-------------|-----------------|
| **UX-1** ✅ | Full HTML shell + this spec | `deploy/studio-demo/` |
| **UX-2** | Tauri/Svelte shell + real editor widget | Replace CodeMirror with embedded editor |
| **UX-2b** | LSP + Problems from real `lic diagnose` | Problems panel live data |
| **UX-3** | GPU viewport | Replace canvas stubs |
| **UX-4** | MCP `ui_cmd_*` + theme schema export | `themes/schema.json` |
| **UX-5** | Infinite canvas | Canvas tab → `li-canvas` |

---

## 6. How to run the wireframe

```bash
cd lic
./scripts/open-studio-design-preview.sh
```

| Try | Action |
|-----|--------|
| Edit user code | **Code** tab → `rocket_logic.li` |
| Patch flow | Agent **Apply patch** or ⌘K → Apply patch |
| Problems | Bottom **Problems** → click row |
| Custom theme | Theme **+** → import `themes/example.custom.json` |
| Focus | Topbar **Focus** |

Capture PNGs: `./scripts/capture-studio-mockup-screenshots.sh`

---

## 7. Anti-patterns (wireframe must not imply shipped)

| Wireframe shows | Do not claim |
|-----------------|--------------|
| CodeMirror | “Li language server shipped” |
| 2D canvas rockets | “GPU viewport shipped” |
| Static problems | “Full compiler diagnostics” |
| Inspector inputs | “Replication live” |

Always pair demos with **composable gate count** or `status.json` when presenting externally.

---

## 8. File manifest

| Path | Purpose |
|------|---------|
| `deploy/studio-demo/index.html` | Full shell DOM |
| `deploy/studio-demo/studio.css` | Chrome tokens + agent dock |
| `deploy/studio-demo/studio-shell.css` | Editor + bottom dock layout |
| `deploy/studio-demo/studio.js` | Viewport + palette + agent |
| `deploy/studio-demo/studio-editor.js` | Code editor + diff |
| `deploy/studio-demo/studio-panels.js` | Problems, inspector, assets, terminal |
| `deploy/studio-demo/studio-files.js` | Virtual project + schemas |
| `deploy/studio-demo/studio-themes.js` | Built-in + custom themes |
| `deploy/studio-demo/themes/schema.json` | User theme JSON schema |
| `deploy/studio-demo/themes/example.custom.json` | Example theme |

**Docs:** this file · [studio-wireframe-ux-audit.md](studio-wireframe-ux-audit.md) · [planned-ui-mockups.md](planned-ui-mockups.md)
