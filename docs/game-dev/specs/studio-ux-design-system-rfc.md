# RFC: Studio UX design system (agent-first)

**Status:** Active (Li stubs + HTML prototype)  
**PH:** PH-UX, PH-GD-1  
**Package:** `li-ui` (`import ui`)

## Problem

Game/sim editors (UE, Unity, Blender) optimize for human muscle memory. Agent-native tools (Cursor, Devin-class) optimize for **machine-readable intent** and **short feedback loops** (`lic build` → patch). World Studio must do both: ≤3 clicks for humans, **zero-ambiguity actions** for agents.

## SOTA synthesis

| Product | Pattern we adopt |
|---------|------------------|
| **VS Code** | Command palette (⌘K), semantic tokens, side bar + panel grid |
| **Cursor** | Agent transcript, apply-after-diagnose, command → patch |
| **Figma** | Layers outliner + contextual inspector |
| **Blender** | Workspace profiles (`ui_layout_*`) |
| **Unreal** | Viewport-centric shell, stat overlays |

## Agent-first rules

1. **Every primary flow is an `UiAgentAction`** — `action_id`, `panel_slot`, `lic_gate`, `target_hash` (diffable).
2. **Command palette is the API surface** — same IDs for UI and MCP (`ui_cmd_*` ↔ `studio_command_execute`).
3. **Transcript lines are typed** — `ui_role_user | agent | system` for replay/training.
4. **Layouts are data** — `UiLayoutProfile` not hard-coded CSS only.
5. **Prove smokes, not pixels** — composable `compile_ok`; HTML demo is illustrative.

## Layout profiles

| `profile_id` | Name | Panels |
|--------------|------|--------|
| 0 | `ui_layout_game_editor` | outliner · viewport · inspector |
| 1 | `ui_layout_agent_first` | outliner · viewport · inspector · **agent dock** |

## Command registry (PH-UX ≤3 clicks)

| `ui_cmd_*` | Human label | Agent `lic` hook |
|------------|-------------|------------------|
| 1 | Play | `lic build` + play session |
| 2 | Pause | stop viewport tick |
| 3 | Build | `lic build` gate |
| 4 | Apply patch | `studio.ai` diagnose + apply |
| 5 | Open world | `world.li` focus |

## Li API (implemented in `packages/li-ui/src/lib.li`)

```li
import ui

var layout: UiLayoutProfile = ui_layout_agent_first()
var cmd: UiCommand = ui_command_new(ui_cmd_lic_build(), 1)
ui_command_palette_execute(cmd)
```

## Phases

| Phase | Deliverable |
|-------|-------------|
| **UX-0** ✅ | Types + smokes + composable gates |
| **UX-1** ✅ | HTML demo: agent dock + ⌘K palette |
| **UX-2** | **Li-only native GUI** — [li-native-gui-plan.md](../plans/li-native-gui-plan.md) (iterate there) |
| **UX-3** | `packages/li-gui` + `world-studio` target + `lic` |
| **UX-4** | In-game creator UI — [li-gui-schema-rfc.md](li-gui-schema-rfc.md) |
| **UX-5** | Infinite agentic canvas — [li-canvas-agentic-rfc.md](li-canvas-agentic-rfc.md) |
| **UX-6** | Creative: scene, anim, seq, video — [li-creative-cinematic-rfc.md](li-creative-cinematic-rfc.md) |
| **UX-4** | MCP tool map `ui_cmd_*` → filesystem paths |
| **UX-5** | GPU present path via `li-render` draw lists |

**Stack decision:** SvelteKit + Tauri for Studio shell; Next.js optional for marketing/docs only (not editor).

## Dependencies

- `li-studio` — shell + `studio_command_execute`
- `li-studio-ai` — patch/diagnose loop
- `li-render` — viewport present

See [agent-first-gui-research.md](../agent-first-gui-research.md).
