# World Studio wireframe UX audit (vs commercial SOTA)

**Artifact:** `lic/deploy/studio-demo/` (HTML prototype, not shipped native UI)  
**Date:** 2026-05-21  
**Verdict:** Structure is **sound for agent-first**; chrome was **too busy** for a wireframe. Competitors win on **visual density discipline** and **motion polish** until native `li-gui` lands.

---

## Executive summary

| Dimension | Wireframe today | Cursor / VS Code | Figma | Blender | Unreal |
|-----------|-----------------|------------------|-------|---------|--------|
| **Information hierarchy** | Good (viewport + agent dock) | Excellent | Excellent | Good (modes) | Good |
| **Busyness** | Was high (10 tabs + dev badges) | Low (tabs + palette) | Low | Medium | Medium–high |
| **Agent UX** | **Differentiator** (plan → gate → apply) | Best-in-class transcript | Weak | None | None |
| **Command surface** | ⌘K + `ui_cmd_*` | ⌘K + command IDs | Quick actions | Search | Content browser |
| **Motion** | Prototype adds subtle motion | Mature micro-interactions | Snappy panels | Workspace swaps | Heavy but polished |
| **Theming** | Built-in + **custom JSON** | Theme marketplace | Variables | Presets | Editor prefs |

**Li edge:** Proof-forward chrome (`lic build · PASS`) and typed agent actions — no competitor combines composable gates + patch loop in-editor.

**Li gap:** Viewport fidelity (canvas stubs), no real property inspector, tab overload vs Blender workspaces / UE toolbar modes.

---

## Structure audit

### What works (keep)

1. **Three-column agent-first shell** — Outliner · viewport · agent rail matches `ui_layout_agent_first` and Cursor’s “editor + chat” without copying it.
2. **Gate chip in top bar** — Single source of truth for build state (vs scattered toasts in Unity).
3. **Command palette = API** — Same IDs for humans (⌘K) and agents (`ui_cmd_N`); aligns with VS Code command table.
4. **Transcript roles** — `user | agent | system` + plan cards → trainable/replayable (ahead of UE/Blender).
5. **Theme tokens as data** — CSS variables + JSON overrides → future `UiThemeProfile` in `li-ui`.

### What was too busy (fixed in prototype)

| Issue | Competitor pattern | Change |
|-------|-------------------|--------|
| 10 equal-weight tabs | Blender: workspace dropdown; UE: mode toolbar | **Workspace `<select>`** with optgroups |
| `feat/agent-first-gui` in top bar | Dev info in status bar / about | Moved to footer |
| Long `gate-count` string | VS Code: compact status items | Truncated + tooltip title |
| Duplicate profile in HUD + inspector | Figma: context in one inspector | HUD shows title only |

### Still wireframe-honest (don’t oversell)

- Canvas scenes are **stubs**, not GPU viewport.
- Inspector panel is placeholder text.
- No real diff viewer (Cursor killer feature).

---

## Interaction audit

### Killer interactions (prototype)

| Interaction | Target | Notes |
|-------------|--------|-------|
| ⌘K palette | VS Code / Cursor | Backdrop dismiss, Enter to run first match |
| `/build` `/patch` hints | Cursor slash commands | Focus composer + prefill |
| Theme swatches + custom JSON | VS Code themes | Import/export, localStorage |
| Workspace switch | Blender workspaces | Cross-fade viewport, no jarring jump |
| Apply patch row | Cursor “Apply” | Primary/secondary/destructive button hierarchy |
| Demo reel | Internal showcase | 8s cadence; pause restores control |

### Gaps vs commercial “killer” bars

1. **No inline diff** — Cursor/VS Code win; add in UX-2 native shell.
2. **No fuzzy palette scoring** — VS Code ranks by usage; agents skip anyway.
3. **No focus mode** — Figma hides chrome; consider “agent focus” collapsing outliner.
4. **No haptic/audio** — Optional; not required for desktop studio.

---

## Animation audit

Principles (added in CSS):

- **150–220ms** UI transitions; **ease-out** for enter, **ease-in** for exit.
- **`prefers-reduced-motion`** disables pulse, viewport fade, palette slide.
- **Gate chip pulse** only when PASS (draws eye without green).

Unreal/Unity use heavier viewport transitions; Li should stay **lighter** until real 3D perf is known.

---

## Custom themes (user contract)

Users can ship themes without forking CSS:

1. Pick built-in **aurora | ember | slate**.
2. **Custom (+)** → import `themes/example.custom.json` or paste JSON.
3. Export / reset from theme panel.

Schema: `deploy/studio-demo/themes/schema.json`.  
Native path: `UiThemeProfile` + `studio.toml` `[theme]` (UX-2).

---

## Recommendations by phase

| Phase | UX priority |
|-------|-------------|
| **UX-1 (now)** | Wireframe discipline, themes, motion, audit doc |
| **UX-2** | Native shell, diff viewer, real inspector |
| **UX-3** | GPU viewport via `li-render` |
| **UX-4** | MCP exports `ui_cmd_*` + theme schema |

---

## Scorecard (1–5, wireframe vs SOTA)

| Criterion | Score | Note |
|-----------|-------|------|
| Clarity | 4 | After workspace select |
| Agent-first | 5 | Unique vs game engines |
| Visual polish | 3 | Wireframe-appropriate |
| Learnability | 4 | Familiar IDE layout |
| Performance feel | 3 | Canvas stubs only |
| Accessibility | 3 | Reduced motion; needs focus ring pass |
| Extensibility | 4 | Themes + command registry |

**Overall:** Strong **UX architecture** for a wireframe; commercial “killer” feel needs native viewport + diff + fewer dev-facing strings in chrome.

See [studio-ux-design-system-rfc.md](specs/studio-ux-design-system-rfc.md), [planned-ui-mockups.md](planned-ui-mockups.md).
