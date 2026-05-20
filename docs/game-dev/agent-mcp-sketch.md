# PH-AGENT-0 — Cursor SDK / MCP sketch (docs-only)

**Status:** Planning stub — no `lis mcp` binary until `lic check --format=json` stabilizes.  
**RFC:** [studio-cursor-sdk-rfc.md](specs/studio-cursor-sdk-rfc.md)

## Goal

Agents drive **Li World Studio** and **Li Engine** via MCP tools, not ad-hoc shell scripts.

## Planned tools (`li-engine` server)

| Tool | Action |
|------|--------|
| `engine_check` | Run `lic diagnose --format=json`; map to `studio_ai_diagnose_gate_stub` — [lic-diagnose-agent-bridge.md](lic-diagnose-agent-bridge.md) |
| `engine_sim_step` | Advance `sim` world N ticks (headless) |
| `engine_studio_play` | Toggle `studio` play/pause on a project handle |
| `engine_chem_stub` | Run `chem.dft_run_stub` for pipeline wiring tests |
| `engine_export_print` | `additive_export_print_stub` via `import sim.additive` |
| `engine_world_save` | `world_save_text_stub` on `WorldSnapshot` |
| `engine_replay_push` | `sim_replay_push` for RL / regression |
| `engine_bioeng_dbtl` | `bioeng_dbtl_advance` + `bioeng_scorecard_rank` |
| `engine_drug_litl` | `lab_loop_advance_stub` on `sim.drug_design` |
| `engine_mmo_realm` | `mmo_smoke` / realm status from `deploy/mmo/realm.toml` |
| `engine_store_presence` | `store_presence_set_stub` via `store.realtime` |

## Safety

- Read-only by default; mutating tools require explicit project token.
- CRITICAL packages (`li-chem`, future `li-sim-drug-design`) log audit events (PH-COMPLY).

## Dependencies

1. `lic diagnose --format=json` (compiler)  
2. Composable `import sim` / `import studio` gates (`li-tests/composable/`)  
3. [portable-targets-rfc.md](specs/portable-targets-rfc.md) + [targets/manifest.toml](../../targets/manifest.toml)
