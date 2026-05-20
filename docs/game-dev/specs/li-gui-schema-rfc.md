# RFC: li-gui schema (UiDocument + user HUD)

**Status:** Draft — tracks [li-native-gui-plan.md](../plans/li-native-gui-plan.md)  
**Policy:** **Li only** — schema, layout, paint, compositor in `packages/li-gui`

## Problem

Studio and shipped games need one **diffable** UI format. Creators build HUDs without foreign UI stacks. Agents patch UI with the same `lic` gates as `world.li`.

## Proposal

### Package

- **`li-gui`** (Li) — `Document`, `Widget`, `Binding`, `Theme`, `PaintList`, `GuiCommand`
- **`li-ui`** — Studio editor `ui_cmd_*` only (not player HUD)
- **`li-gpu` / `li-render`** — consume paint IR; no separate Rust/TS UI tree

### Widget kinds (v1)

`Panel`, `Label`, `Button`, `Progress`, `Image`, `Grid`, `Scroll`

### Binding grammar (draft)

```text
bind_path ::= "player." ident | "world." entity "." field
```

Invalid paths → **`lic build` error**.

### Commands

| Namespace | Scope |
|-----------|--------|
| `ui_cmd_*` | World Studio (`li-ui`) |
| `gui.cmd(...)` | In-game (`li-gui`) |

### Export

`lic build` emits `gui.manifest.json` for agents (widget ids, binds, cmds).

## Phases

See [li-native-gui-plan.md §9](../plans/li-native-gui-plan.md#9-implementation-phases-li-only).

## Open questions

- [ ] Syntax: constructors vs `gui` DSL macros?
- [ ] Theme inheritance?
- [ ] Animation in v1 or v2?
