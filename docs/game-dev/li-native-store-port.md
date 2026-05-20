# Li-native store port (MMO / realtime)

**Policy:** [li-native-first.mdc](../../.cursor/rules/li-native-first.mdc)

## Principle

Port **semantics** (pub/sub, presence, replay buffers) into **`li-store-realtime`** — do not require Redis/Postgres processes for core composable gates.

| Layer | Role |
|-------|------|
| **`store_backend_li_native()`** | Default in-memory Li implementation |
| **`store_backend_memory()`** | Dev stub handle |
| **`store_backend_redis/postgres()`** | Optional trusted `extern` pings for deploy labs only |

## API (impl-34)

- `store_li_native_open` / `store_li_native_presence_set` / `store_li_native_pub`
- `store_li_native_replay_push` / `store_li_native_smoke`
- Composable: `import_store_li_native`, `import_ecosystem_li_native_stack`

## Gates

```bash
./li-tests/run_all.sh composable   # import_store_li_native
```
