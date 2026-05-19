# `lic diagnose` → Studio AI bridge (PH-AGENT-1)

**Status:** Schema stub — wire when `lic diagnose --format=json` is stable.

## Flow

```text
Agent → engine_check(path) → lic diagnose --format=json
       → studio_ai_diagnose_gate_stub(error_count)
       → studio_ai_apply_if_clean_stub(patch, error_count)
```

## Expected JSON shape (illustrative)

```json
{
  "ok": true,
  "error_count": 0,
  "diagnostics": []
}
```

## Li mapping

| JSON field | Studio AI |
|------------|-----------|
| `error_count` | `studio_ai_diagnose_gate_stub` |
| `ok == false` | block `studio_ai_apply_patch` |

## MCP tool

See [agent-mcp-sketch.md](agent-mcp-sketch.md) — `engine_check` returns parsed `error_count`.
