# Agent-first GUI research (SOTA → Li `li-ui`)

## Design thesis

**Agents do not click.** They need:

- Stable **action IDs** (not screen coordinates)
- **Verifiable gates** before mutation (`lic build`, diagnose JSON)
- **Transcripts** with roles for replay
- **Layouts** as values agents can request (“switch to drug LITL workspace”)

Humans need ≤3 clicks and familiar editor chrome. **One registry** serves both.

## Reference products

### VS Code / Cursor

- **Command palette** centralizes discoverability; fuzzy search is human-only — agents call `cmd_id` directly.
- **Problems panel** maps to `lic diagnose` — we mirror with `studio_ai_diagnose_gate_stub`.
- **Diff-first** editing — agents patch `world.li`; humans preview in viewport.

### Figma

- **Layers = outliner** — `ui_panel_outliner`, entity ids hash to `target_hash`.
- **Properties = inspector** — component_mask style fields in `world` replication API.

### Blender

- **Workspaces** — `UiLayoutProfile` per vertical (game / sim / drug / MMO).
- **Mode switching** — `studio_adaptive_panel_for_stage` (already in `li-studio`).

### Unreal / Unity

- **Viewport-first** — 1280×720 default; stats overlay → benchmark honesty.
- **Play-in-editor** — `studio_command_execute(ui_cmd_play)`.

## Li implementation map

| Concept | Package | Symbol |
|---------|---------|--------|
| Layout | `li-ui` | `ui_layout_agent_first` |
| Commands | `li-ui` + `li-studio` | `ui_cmd_*` / `studio_cmd_*` |
| Agent patch | `li-studio-ai` | `studio_ai_apply_if_clean_stub` |
| Demo shell | `deploy/studio-demo` | HTML prototype only — canonical UI is Li ([plan](plans/li-native-gui-plan.md)) |
| Proof | `li-tests` composable | `import_ui_agent_studio_stack` |

## Anti-patterns (forbidden claims)

| Don’t | Do |
|-------|-----|
| “Native GPU UI shipped” | “HTML prototype + Li UI types + composable gates” |
| Screenshot-only demos | `status.json` + composable count |
| Agent without build gate | `lic_gate` on every `UiAgentAction` |

## Next engineering

1. MCP schema export from `ui_cmd_*` table  
2. `li-studio` reads `UiLayoutProfile` in native binary  
3. Accessibility: focus order as `int` list in `UiFrame`  

See [studio-ux-design-system-rfc.md](specs/studio-ux-design-system-rfc.md).
