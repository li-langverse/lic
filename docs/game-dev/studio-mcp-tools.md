# Studio MCP tools (PH-AGENT contract)

**Status:** AGENT-0 scaffold (contracts only)  
**Vision:** [world-studio-vision.md](world-studio-vision.md) §18  
**RFC:** [specs/studio-cursor-sdk-rfc.md](specs/studio-cursor-sdk-rfc.md)

Li World Studio agents call these tools via MCP (`lis mcp li-engine`) once PH-AGENT-1+ lands. This document and `packages/li-studio` define **stable tool IDs and names** only — no HTTP MCP server or `@cursor/sdk` wiring in AGENT-0.

## Proof gate

Any tool that mutates project state or ships artifacts must run **`lic build`** (and typically `lic check --format=json` first). Agent chrome surfaces `studio_mcp_lic_build` as the proof gate tool; failed proof maps to `studio_mcp_tool_result_err_proof`.

## Tool table

| ID constant | MCP name | Conceptual args | Action |
|-------------|----------|-----------------|--------|
| `studio_mcp_world_scaffold` | `world_scaffold` | `template_id: str`, `target_dir: str` | Create `world.li` + `assets/` + `studio.toml` from spin-up template |
| `studio_mcp_sim_set_profile` | `sim_set_profile` | `profile: str` (e.g. `sim_additive`) | Set `[engine] profile` in `studio.toml` |
| `studio_mcp_lic_check` | `lic_check` | `paths: str[]` (optional) | Run `lic check --format=json`; return diagnostics |
| `studio_mcp_lic_build` | `lic_build` | `target: str` (optional triple) | Run `lic build`; **required** before publish/export |
| `studio_mcp_publish_bundle` | `publish_bundle` | `out_path: str` | Write repro bundle (SVG/HDF5/manifest) after proof pass |

## Runtime API (`import studio`)

| Symbol | Role |
|--------|------|
| `studio_mcp_tool_count()` | Returns `5` |
| `studio_mcp_tool_name(id)` | Round-trip name via `li_rt` const table |
| `studio_mcp_tool_from_name(name)` | Parse MCP tool name → ID |
| `studio_mcp_tool_id_valid(id)` | Non-zero IDs only |
| `StudioAgentToolRequest` | `tool_id`, `status`, `result_code` on agent chrome |
| `studio_compose_agent_chrome_with_tool` | Optional tool request on compose |

## Status / result codes (stub)

| Status | Constant |
|--------|----------|
| idle | `studio_mcp_tool_status_idle` |
| pending | `studio_mcp_tool_status_pending` |
| ok | `studio_mcp_tool_status_ok` |
| failed | `studio_mcp_tool_status_failed` |

| Result | Constant |
|--------|----------|
| ok | `studio_mcp_tool_result_ok` |
| proof failure | `studio_mcp_tool_result_err_proof` |
| I/O | `studio_mcp_tool_result_err_io` |

## Smoke

`packages/li-studio/li-tests/smoke/studio_mcp_tools.li` — ID/name round-trip and agent chrome optional field.

## Not in AGENT-0

- `lis` HTTP MCP server implementation
- `@cursor/sdk` agent session wiring
- Tools from vision not in wave-1 set: `am_export_print`, `chem_dft_run`, `studio_adaptive_layout`
