# li-world

Text-line world snapshot save/load for Li Engine (PH-GD-2). Single-line `world.li` file I/O via trusted runtime; no binary format or scene graph yet.

Import: `import world`

## Format

`world_v1 name=<id> tick=<n> entity_count=<m>` — single line per snapshot; names are token-safe (no spaces) until full scene graph lands.

## API

- `world_format_version` — format id (`1`)
- `WorldSnapshot` — `name` (stub slot id: 0=`default`, 1=`arena`), `tick`, `entity_count`
- `world_serialize` / `world_parse_line` — line ↔ snapshot
- `world_save_to_buffer` / `world_load_from_buffer` — in-memory string round-trip
- `world_save_to_path` / `world_load_from_path` — write/read one `world_v1` line to a file path
- `world_checkpoint_path_default` — `LI_WORLD_CHECKPOINT_PATH` or `/tmp/li_world_checkpoint.li`
- `world_file_roundtrip_ok` — serialize → file → parse field match

## Evidence

- `li-tests/smoke/world_roundtrip.li`
- `li-tests/smoke/world_file_roundtrip.li`
