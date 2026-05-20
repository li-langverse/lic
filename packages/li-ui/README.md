# li-ui

**Agent-first immediate-mode UI** for World Studio (PH-UX).

## Import

```li
import ui
```

## SOTA patterns

| API | Inspired by |
|-----|-------------|
| `ui_command_*` / `ui_cmd_*` | VS Code / Cursor command palette |
| `ui_layout_agent_first` | Cursor agent dock + Figma panels |
| `UiAgentAction` | Machine-readable intents for MCP |
| `ui_transcript_*` | Agent chat roles (user / agent / system) |

## Docs

- [agent-first-gui-research.md](../../docs/game-dev/agent-first-gui-research.md)
- [studio-ux-design-system-rfc.md](../../docs/game-dev/specs/studio-ux-design-system-rfc.md)
- HTML prototype: `deploy/studio-demo/` (⌘K + agent dock)

## Proof

```bash
lic build packages/li-ui/src/lib.li -o /tmp/ui-smoke
./li-tests/run_all.sh composable  # import_ui_agent_palette, import_ui_agent_studio_stack
```
