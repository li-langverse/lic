# Li-native proxy relay (`use_native_proxy_relay`)

## Architecture (C shim vs Li)

| Concern | C (`runtime/li_rt_net.c`) | Li (`proxy_relay_native.li`, `lib.li`) |
|--------|---------------------------|----------------------------------------|
| epoll / tagged fds | `epoll_wait_tagged_*`, listen accept | `httpd_upstream_proxy_epoll_loop` |
| Request + response headers | `httpd_li_proxy_*_epoll_i` (unchanged) | — |
| CL body relay under load | `httpd_proxy_pump_cl_relay` (same path as legacy) | Oracle: `relay_cl_take`, `relay_finish_ready` |
| Fairness / TLS starvation | `httpd_proxy_fair_relay_round_i` | `proxy_native_fair_relay_round` → delegates to C fair round |
| Byte accounting | `httpd_proxy_relay_cl_account` on forward | Li oracle validates finish (`relay_finish_ready`) |
| Finish gate | `httpd_proxy_relay_complete` | `relay_finish_ready`, `proxy_li_try_finish` (unit/oracle) |

When the native flag is on, **scheduling and CL pumping use the proven C fair-round / pump path** (`8547e8fd7+`). The flag enables config/env wiring and Li oracle gates; it does not route CL I/O through a separate Li pump loop.

## Feature flag

- Config: `[limits] use_native_proxy_relay = true`
- Env: `LI_HTTPD_USE_NATIVE_PROXY_RELAY=1` (overrides toml when set)
- C API: `httpd_use_native_proxy_relay_i()`

## Tests

- `packages/li-net-httpd/src/proxy_relay_native.li` — standalone oracle
- `li-tests/httpd/proxy_relay_native_test.li` — imports `net.httpd`
- `make test-proxy-c` — C oracle + native oracle
- Docker: `test/gitlab-proxy/` parallel 18 gate (WSL — see below)
- blackpearl: `homelab-k3s/scripts/edge-parallel-18-probe.sh` with `EDGE_PROBE_RESOLVE=…:8443:…`

## WSL Docker gate (`test/gitlab-proxy`)

**Environment-only flakiness (not a native-relay logic split).** On WSL2 Docker Desktop (2026-06-10, lic `8547e8fd7`):

| Observation | Detail |
|-------------|--------|
| `use_native_proxy_relay=0` vs `1` | Both ~11–16/18; no meaningful gap after C-path unification |
| `test/proxy-repro` on same host | 0/10 (sign_in `000`) — broader Docker TLS/env issue |
| Best after healthcheck + `workers=1` | 16/18 once; not stable ×3 |
| Failure modes | Empty wire (`code 000`), truncation ~100–120 KiB on large assets |
| Acceptance host | **blackpearl loopback/LAN** (`edge-parallel-18-probe.sh`) — not WSL Docker |

Gate recipe (best effort on WSL): `docker compose build --no-cache proxy`, proxy healthcheck, `LI_HTTPD_WORKERS=1`, `concurrent_streams=64`, tester `depends_on: service_healthy`.

## Gate status (2026-06-10)

| Gate | Status | Notes |
|------|--------|-------|
| `proxy_relay_native.li` oracle | PASS | |
| C `proxy_relay_oracle.li` | PASS | |
| `make test-proxy-c` | PASS | 5/5 |
| Docker gitlab parallel 18 (WSL) | FLAKY / ENV | 11–16/18; see WSL section |
| blackpearl `:8443` + native flag | see round-3 probe | `8547e8fd7` |
| homelab-k3s npm/Playwright | pending blackpearl 18/18 | |
