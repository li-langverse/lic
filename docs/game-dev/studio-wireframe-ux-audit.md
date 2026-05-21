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

---

## UX dimensions (evaluation lens)

Use these when comparing **wireframe / stubs today** vs shipped competitors:

| # | Dimension | Question |
|---|-----------|----------|
| D1 | **Primary surface** | Is the hero canvas viewport/graph believable at 60fps? |
| D2 | **Hierarchy & selection** | Can users scope edits in one click (outliner ↔ viewport)? |
| D3 | **Inspector / properties** | Typed fields, units, sliders, live preview? |
| D4 | **Direct manipulation** | Gizmos, drag, snap, multi-select? |
| D5 | **Run / transport** | Play/pause/step/bench — obvious and reversible? |
| D6 | **Commands & shortcuts** | Palette, keybindings, discoverability? |
| D7 | **Agent collaboration** | Transcript, context, apply, trust? |
| D8 | **Diagnostics** | Problems panel, jump-to-error, structured JSON? |
| D9 | **Trust & proof** | Build gate, validity, repro hash — visible? |
| D10 | **Workflow depth** | Timeline, stages, job queue, export wizards? |
| D11 | **Assets & pipeline** | Import, browser, thumbnails, search? |
| D12 | **Polish & density** | Motion, spacing, not busy, professional? |
| D13 | **Onboarding** | First-run, templates, tooltips? |
| D14 | **Accessibility** | Focus rings, contrast, reduced motion, screen reader? |
| D15 | **Customization** | Themes, workspaces, bindable keys? |
| D16 | **Collaboration** | Comments, presence, shared sessions? |

**➕ Li leads on D9** (and D7 architecture) vs every game engine and most IDEs. **Li lags on D1–D4, D8, D10–D11** vs domain leaders.

---

## Where Li lacks UX — by competitor × dimension

Severity: **H** high (blocks “commercial feel”), **M** medium, **L** low / intentional defer.

### Cursor

| Dim | Gap | Sev |
|-----|-----|-----|
| D7 | No **inline diff** / side-by-side patch preview before Apply | H |
| D7 | No **@file / @selection** affordances in composer | H |
| D7 | No streaming partial response / stop / regenerate UX | M |
| D6 | Palette has no **fuzzy rank** or recent commands | M |
| D8 | No **Problems** panel listing `lic diagnose` rows with click-to-jump | H |
| D7 | No rules/skills picker surfaced in chrome | M |
| D11 | No codebase index search (symbols) in UI | M |
| D9 | ➕ Li **wins**: gate chip + composable proof in toolbar | — |

### VS Code

| Dim | Gap | Sev |
|-----|-----|-----|
| D6 | No **keybinding editor** or chord hints on hover | M |
| D8 | No dedicated **Problems / Output / Terminal** strip | H |
| D11 | No **SCM** view (git diff, stage, blame) | H |
| D3 | No multi-file **tabs** or breadcrumbs | M |
| D13 | No extension marketplace / settings UI | M |
| D14 | Focus ring pass incomplete on wireframe | M |
| D7 | Agent exists; VS Code **Copilot Chat** has thread list + references | M |

### Figma

| Dim | Gap | Sev |
|-----|-----|-----|
| D1 | No **infinite pan/zoom** design canvas (future `gui.canvas`) | H |
| D12 | Chrome still **denser** than UI3 minimal top bar | M |
| D16 | No multiplayer cursors / comments | L (v2) |
| D3 | No **component variants** or design-token bind UI | H |
| D1 | No vector editing / frames / sections | H |
| D9 | ➕ Li **wins**: compile + sim path past “handoff” | — |

### Blender

| Dim | Gap | Sev |
|-----|-----|-----|
| D4 | No transform **gizmos** (move/rotate/scale) | H |
| D2 | Outliner: no icons, drag-reparent, collections | H |
| D3 | Inspector is **placeholder text**, not live props | H |
| D5 | No mode switching (Object/Edit/Pose) muscle memory | M |
| D10 | Sequencer / VSE **not in wireframe** (future cinematic) | M |
| D6 | No **searchable** operator menu (Spacebar-style) | M |
| D11 | No asset browser / preview thumbnails | H |

### Unreal Engine

| Dim | Gap | Sev |
|-----|-----|-----|
| D1 | Viewport is **2D canvas stub**, not Lumen/Nanite-class 3D | H |
| D11 | No **Content Browser** (filter, drag into level) | H |
| D3 | Details panel depth (materials, components) missing | H |
| D10 | **Sequencer + MRQ** export UX not wired | H |
| D5 | PIE (Play In Editor) **feel** — no embedded play window | M |
| D4 | No placement/snap/grid; no camera bookmarks | M |
| D12 | Toolbar modes (Landscape, foliage…) intentionally omitted — migrants feel loss | M |
| D9 | ➕ Li **wins**: bench validity + `world.li` text, not `.uasset` | — |

### Unity

| Dim | Gap | Sev |
|-----|-----|-----|
| D1 | No **Scene vs Game** view split; no play-mode tint | M |
| D3 | Inspector serialization (foldouts, arrays, refs) missing | H |
| D2 | Hierarchy drag-drop, prefab overrides UI | H |
| D11 | Package Manager / Asset Store patterns absent | M |
| D3 | **UI Toolkit** visual editor parity (Unity 6+) | H |
| D5 | Transport cluster less discoverable than Unity center bar | L |

### Cross-cutting (Li lacks vs *most* competitors)

| Dim | Gap | Who does it best |
|-----|-----|------------------|
| D1 | Real **GPU viewport** (`li-render`) | UE, Unity, Blender |
| D3 | Live **inspector** bound to selection | UE, Unity, COMSOL, Figma |
| D4 | **Gizmo** manipulation | Blender, UE, Unity |
| D8 | **Problems** surface + navigation | VS Code, Cursor |
| D10 | Profile-specific **bottom strips** (timeline, LITL, bench) | UE Sequencer, Benchling, COMSOL |
| D11 | **Asset browser** + import progress | UE, Unity, Blender |
| D13 | **Spin-up templates** as first-run (we have deploy templates, not UX) | Roblox, UE templates |
| D16 | Real-time **collab** | Figma, FigJam |

### Where Li must *not* copy (avoid UX debt)

| Competitor trap | Li rule |
|-----------------|---------|
| UE toolbar overload | Workspace select + pins (done in wireframe) |
| Unity dual UI stacks | One shell, `li-ui` types |
| Figma without runtime | Always show **gate + validity** |
| Cursor without proof | Never ship “Apply” without `lic_gate` |

Full domain matrix (14 industries): [competitive-intel/ui-ux-by-dimension.md](competitive-intel/ui-ux-by-dimension.md).

**Wireframe implementation:** [studio-wireframe-full-spec.md](studio-wireframe-full-spec.md) — code editor, problems, diff, inspector, assets, terminal, timeline.
