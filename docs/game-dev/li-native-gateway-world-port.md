# Li-native gateway + world persist port

**Policy:** [li-native-first.mdc](../../.cursor/rules/li-native-first.mdc)

## HTTP / WebSocket (`li-net-httpd`)

Port gateway semantics into Li — **no Node.js or external WS server** for composable gates.

| API | Role |
|-----|------|
| `httpd_li_native_gateway_tick_stub` | Listen + upgrade + bind player in one Li tick |
| `httpd_li_native_gateway_smoke` | Full WS smoke path |

Composable: `import_httpd_li_native_gateway`

## World persist (`li-world`)

| API | Role |
|-----|------|
| `WorldLiJournal` | In-memory realm journal |
| `world_li_native_journal_append` | Append snapshot checksum |
| `world_li_native_persist_smoke` | Journal + load round-trip |

Composable: `import_world_li_native_persist`

## Full stack

`import_ecosystem_gateway_realm_li_native` — httpd + mmo + world + store Li-native + `sim_profile_mmo`.
