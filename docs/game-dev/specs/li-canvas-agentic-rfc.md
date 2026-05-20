# RFC: Infinite agentic canvas (`gui.canvas`)

**Status:** Draft  
**Parent:** [li-native-gui-plan.md](../plans/li-native-gui-plan.md) v0.3  
**Policy:** Li only — `packages/li-gui` module `gui.canvas`

## Problem

Linear outliner + single viewport is not how agents (or creators) **reason** about multi-realm games, sim profiles, HUDs, and benchmarks. We need an **infinite spatial workspace** with **typed links** and **`lic build`** on selections — Figma/Miro-class canvas, Blueprint-class gates, Cursor-class agent cards.

## Proposal

### Scope

| In scope | Out of scope |
|----------|----------------|
| Studio authoring canvas | Player-facing infinite scroll UI |
| Pan/zoom, tiles, LOD | Freehand drawing / whiteboard art |
| Node + link Li types | 3D scene graph (use `li-render` embed) |

### Core types (Li)

- `CanvasDocument`, `CanvasCamera`, `CanvasNode`, `CanvasLink`, `CanvasTileKey`
- `CanvasNodeKind`: World, GuiScreen, SimField, AgentPlan, Note, BenchRef, Realm
- `CanvasLinkKind`: Spawns, Binds, Replicates, Documents, DependsOn, AgentEdited

### Authoring

- File: `canvas/world.canvas.li` or `world.canvas.li`
- Export: `canvas.manifest.json` (agent spatial index)

### Agent MCP (future)

`canvas_add_node`, `canvas_link`, `canvas_focus`, `canvas_compile_selection`

### Performance

- Tile-based cull; 60 fps pan/zoom on 1k nodes (target)
- Phase G5 bench hook: `canvas_frame_pan_zoom` (Li-only)

## Phases

See parent plan **Phase G5**.

## Open questions

- [ ] Single graph per repo or multiple `canvas/*.li`?
- [ ] Collaborative editing (OT/CRDT) — defer?
