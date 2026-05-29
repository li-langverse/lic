# li-world `world.li` file I/O (PH-GD-2)

**Date:** 2026-05-27  
**Branch:** `feat/studio-real-implementation`  
**PH / REQ:** PH-GD-2  

## Summary

PH-GD-2 advances from in-memory buffer round-trip to honest single-line `world.li` file save/load via `li_rt_world_write_path` / `li_rt_world_read_path`. Studio game checkpoint roundtrip now exercises buffer + default checkpoint path.

## How to verify

1. Read: `packages/li-world/src/lib.li`, `packages/li-studio/src/lib.li` (`studio_game_world_checkpoint_*`), `runtime/li_rt.c` (`li_rt_world_*_path`).
2. Run: `lic check packages/li-world` and `lic check packages/li-studio`.
3. Optional: `LI_WORLD_CHECKPOINT_PATH=/tmp/my_world.li` for custom smoke path.

## Surface

| Location | API | Gate |
|----------|-----|------|
| `packages/li-world` | `world_save_to_path`, `world_load_from_path`, `world_file_roundtrip_ok`, `world_checkpoint_path_default` | `world_file_roundtrip.li` |
| `packages/li-studio` | `studio_game_world_checkpoint_path`, `studio_game_world_checkpoint_file_roundtrip` | `studio_game_step_hook.li` |
| `runtime/li_rt.c` | `li_rt_world_write_path`, `li_rt_world_read_path`, `li_rt_world_checkpoint_path_default` | file round-trip smokes |

## Example path

Default checkpoint file: `/tmp/li_world_checkpoint.li` (override with `LI_WORLD_CHECKPOINT_PATH`).

Example line written:

```text
world_v1 name=arena tick=2 entity_count=1
```

## Still stub

- `studio_game_entity_count_stub` — fixed entity count
- Scene graph, assets refs, MCP `world_scaffold` execution (WP-GD-03)
- Multi-entity / composable `world.li` document format
