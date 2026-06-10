# Li-native proxy relay (`use_native_proxy_relay`)

## Architecture (C shim vs Li)

| Concern | C (`runtime/li_rt_net.c`) | Li (`proxy_relay_native.li`, `lib.li`) |
|--------|---------------------------|----------------------------------------|
| epoll / tagged fds | `epoll_wait_tagged_*`, listen accept | `httpd_upstream_proxy_epoll_loop` |
| Request + response headers | `httpd_li_proxy_*_epoll_i` (unchanged) | — |
| CL body relay under load | `httpd_proxy_pump_cl_relay` **skipped** when native | `proxy_li_pump_cl` + `relay_cl_take` |
| Fairness / TLS starvation | reconcile + sweep shims | `proxy_native_fair_relay_round` → `proxy_li_service_slot` |
| Byte accounting | mirror getters only | `relay_account_body`, `proxy_li_sync_body_left` |
| Finish gate | `httpd_native_proxy_relay_complete_i` | `relay_finish_ready`, `proxy_li_try_finish` |
| Upstream hold | TLS/rbuf pending in C | `relay_upstream_blocked` |

## State machine

`READ_UPSTREAM` → `RELAY_CLIENT` → `DRAIN_TLS` → `FINISH`

Implemented in Li oracle; C epoll handles phases 1–2 headers; native fair round drives CL relay + finish.

## Feature flag

- Config: `[limits] use_native_proxy_relay = true`
- Env: `LI_HTTPD_USE_NATIVE_PROXY_RELAY=1`
- C API: `httpd_use_native_proxy_relay_i()`

Legacy C relay remains when flag is off (`httpd_proxy_fair_relay_round_i`).

## Tests

- `packages/li-net-httpd/src/proxy_relay_native.li` — standalone oracle
- `li-tests/httpd/proxy_relay_native_test.li` — imports `net.httpd`
- Docker: `test/gitlab-proxy/` parallel 18 gate
