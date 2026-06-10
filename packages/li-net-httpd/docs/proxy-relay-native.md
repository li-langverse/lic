# Li-native proxy relay (`use_native_proxy_relay`)

## Architecture (C shim vs Li)

| Concern | C (`runtime/li_rt_net.c`) | Li (`proxy_relay_native.li`, `lib.li`) |
|--------|---------------------------|----------------------------------------|
| epoll / tagged fds | `epoll_wait_tagged_*`, listen accept | `httpd_upstream_proxy_epoll_loop` |
| Request + response headers | `httpd_li_proxy_*_epoll_i` (unchanged) | — |
| CL body relay under load | `httpd_proxy_pump_cl_relay` **skipped** when native | `proxy_li_pump_cl` + `relay_cl_take` |
| Fairness / TLS starvation | reconcile + sweep shims | `proxy_native_fair_relay_round` → `proxy_li_service_slot` |
| Byte accounting | `g_native_cl_account_pending` queue only | `relay_account_body`, `proxy_li_sync_body_left`, `proxy_li_drain_native_accounted` |
| Finish gate | `httpd_native_proxy_relay_complete_i` | `relay_finish_ready`, `proxy_li_try_finish` |
| Upstream hold | TLS/rbuf pending in C | `relay_upstream_blocked` |

## State machine

`READ_UPSTREAM` → `RELAY_CLIENT` → `DRAIN_TLS` → `FINISH`

Implemented in Li oracle; C epoll handles phases 1–2 headers; native fair round drives CL relay + finish.

## Byte accounting flow (native)

1. C I/O paths (`relay_to_client`, rbuf flush, TLS defer flush) enqueue consumed bytes in `g_native_cl_account_pending[slot]` instead of decrementing `body_left`.
2. Li `proxy_li_drain_native_accounted` pulls the queue and applies `relay_account_body` oracle via `proxy_li_sync_body_left`.
3. `proxy_li_pump_cl` applies oracle directly after splice/forward (`relay_cl_take` caps take; `proxy_li_sync_body_left` decrements).
4. `httpd_li_proxy_forward_bytes_i` does **not** account in C when native — pump owns accounting.

## Feature flag

- Config: `[limits] use_native_proxy_relay = true`
- Env: `LI_HTTPD_USE_NATIVE_PROXY_RELAY=1`
- C API: `httpd_use_native_proxy_relay_i()`

Legacy C relay remains when flag is off (`httpd_proxy_fair_relay_round_i`).

## Tests

- `packages/li-net-httpd/src/proxy_relay_native.li` — standalone oracle
- `li-tests/httpd/proxy_relay_native_test.li` — imports `net.httpd`
- `test/proxy-relay/run-unit-tests.sh` — C oracle + native oracle + parallel gates
- Docker: `test/gitlab-proxy/` parallel 18 gate

## Gate status (2026-06-10)

| Gate | Status | Notes |
|------|--------|-------|
| `proxy_relay_native.li` oracle | PASS | standalone build |
| C `proxy_relay_oracle.li` | PASS | after defer-queue selftest fix |
| `make test-proxy-c` | PASS | 5/5 unit scripts |
| Docker gitlab parallel 18 | FLAKY | 9–10/18 in WSL docker; truncation fix landed, empty-wire races remain under 18-way TLS |
| blackpearl :8443 | NOT TESTED | deploy pending |
| homelab-k3s npm/Playwright | NOT TESTED | native-only gate documented above |

Native relay requires: Li `proxy_li_pump_cl` + fair round, C epoll CL pump skipped, byte accounting via `g_native_cl_account_pending` → `proxy_li_sync_body_left`, upstream EPOLLIN routed to Li only during CL body (headers stay on C epoll).
