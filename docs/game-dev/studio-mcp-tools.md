# Studio MCP tools (PH-AGENT contract)

**Status:** AGENT-2 partial (stdio MCP server + runtime dispatch + proof gate + in-process harness)  
**Vision:** [world-studio-vision.md](world-studio-vision.md) §18  
**RFC:** [specs/studio-cursor-sdk-rfc.md](specs/studio-cursor-sdk-rfc.md)

Li World Studio agents call these tools via MCP (`lis mcp li-engine`). In-tree **stdio MCP** is available via `scripts/lis-mcp-li-engine` (PH-AGENT-2); the separate `lis` CLI will register the same entrypoint later. HTTP transport and `@cursor/sdk` session wiring remain future work.

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
| `studio_mcp_am_export_print` | `am_export_print` | `job_path: str`, `printer_id: str` (optional) | Export slice/mesh to printer pipeline (stub) |
| `studio_mcp_chem_dft_run` | `chem_dft_run` | `input_path: str`, `method: str` (optional) | Queue QM/DFT job via `li-chem` (stub) |
| `studio_mcp_studio_adaptive_layout` | `studio_adaptive_layout` | `role: str`, `stage: str` | Drug/role adaptive shell layout (`layout_studio_shell_adaptive`) |

## Runtime API (`import studio`)

| Symbol | Role |
|--------|------|
| `studio_mcp_tool_count()` | Returns `8` |
| `studio_mcp_tool_dispatch(tool_id)` | Runtime dispatch via `li_rt_studio_mcp_dispatch`; proof gate on `lic_*` / `publish_bundle`; chem/adaptive Li hooks |
| `studio_mcp_harness_run_all()` | In-process harness: dispatch all 8 tool IDs (build before publish); smoke `studio_mcp_harness_all_tools.li` |
| `studio_mcp_last_profile_id()` | Last profile set by `sim_set_profile` dispatch (`STUDIO_MCP_PROFILE` env) |
| `studio_mcp_chem_dft_energy_hartree()` | Stub energy (`-76.0` Hartree) aligned with `li-chem` smoke |
| `studio_mcp_tool_name(id)` | Round-trip name via `li_rt` const table |
| `studio_mcp_tool_from_name(name)` | Parse MCP tool name → ID |
| `studio_mcp_tool_id_valid(id)` | Non-zero IDs only |
| `StudioAgentToolRequest` | `tool_id`, `status`, `result_code` on agent chrome |
| `studio_compose_agent_chrome_with_tool` | Optional tool request on compose |

## Environment (AGENT-1 dispatch)

| Variable | Effect |
|----------|--------|
| `STUDIO_MCP_PROOF_FAIL=1` | `lic_check` / `lic_build` return proof error; blocks `publish_bundle` |
| `STUDIO_MCP_PROFILE` | Profile slug for `sim_set_profile` (default `game`) |

## Status / result codes

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

## MCP server (`lis mcp li-engine`)

| Item | Value |
|------|-------|
| Transport | **stdio** (newline-delimited JSON-RPC 2.0, MCP 2024-11-05) |
| Binary | `build/tools/studio-mcp-li-engine` (built by `scripts/build-studio-mcp-server.sh`) |
| Shim | `scripts/lis-mcp-li-engine` — use until `lis` registers `mcp li-engine` |
| Dispatch | `li_rt_studio_mcp_dispatch` + proof gate (`lic_build` before `publish_bundle`) |
| Tools | All **8** MCP names from the tool table (`tools/list`, `tools/call`) |

### Cursor / MCP client config

```json
{
  "mcpServers": {
    "li-engine": {
      "command": "/path/to/lic/scripts/lis-mcp-li-engine",
      "env": {
        "STUDIO_MCP_PROFILE": "game"
      }
    }
  }
}
```

### Build and verify

```bash
./scripts/build-studio-mcp-server.sh
./scripts/check-studio-mcp-server.sh   # MCP RPC smoke (+ Li harness when lib.li check passes)
```

## Smoke

- `scripts/check-studio-mcp-server.sh` / `li-tests/tooling/studio_mcp_server_smoke.py` — stdio MCP `tools/list` (8 tools), all 8 `tools/call`, proof gate (`publish_bundle` before/after `lic_build`), chem energy.
- `packages/li-studio/li-tests/smoke/studio_mcp_tools.li` — wave-1 ID/name round-trip and agent chrome optional field.
- `packages/li-studio/li-tests/smoke/studio_mcp_extended.li` — gap #6/#7 tool IDs, `studio_mcp_tool_dispatch`, adaptive layout hook.
- `packages/li-studio/li-tests/smoke/studio_mcp_dispatch_run.li` — proof gate (`lic_build` → `publish_bundle`), chem energy, `sim_set_profile`.
- `packages/li-studio/li-tests/smoke/studio_mcp_harness_all_tools.li` — all 8 MCP tool IDs via `studio_mcp_harness_run_all`.
- `li-tests/composable/import_lig_chem_backend.li` — `chem_dft_run_smoke()` stub energy (`-76.0` Hartree); `chem_lig_backend_auto` unchanged.

## Not in this slice

- `lis` CLI subcommand registration (`mcp li-engine` → delegate to `scripts/lis-mcp-li-engine`)
- HTTP/SSE MCP transport
- `@cursor/sdk` agent session wiring
- Real `am_export_print` queue / external `lic` subprocess from MCP
