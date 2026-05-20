# Cursor / IDE agents — competitive notes

**Dimension:** [IDE §12](../ui-ux-by-dimension.md#12-ide-notebooks--agents)

## UI/UX to steal

- ⌘K command palette  
- Agent transcript + apply  
- Problems panel from diagnostics  
- Rules / project context

## Li mapping

| Cursor | Li |
|--------|-----|
| Palette | `ui_cmd_*` |
| Agent | `UiAgentAction` + MCP |
| Problems | `lic diagnose` JSON |
| Apply | Patch `*.li` only |

➕ **`lic build` gate** before play/sim/export — Cursor does not own runtime validity.
