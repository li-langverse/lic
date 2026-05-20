# Nginx-style reverse proxy → Li-native epoll (migration)

## Nginx model we mirror

From tier-5 harness `nginx_lb_proxy_prefix_conf` (see `benchmarks` / `lis-tier5` `bench_http.py`):

| Nginx directive | Li equivalent (today) |
|-----------------|----------------------|
| `upstream { keepalive 32; }` | `httpd_upstream_acquire_i` / `release_i` pool in `li_rt_net.c` |
| `proxy_http_version 1.1` | Request forwarded as HTTP/1.1 bytes on upstream socket |
| `proxy_set_header Connection ""` | `httpd_proxy_compact_req_hdr()` strips `Connection:` / `Proxy-Connection:` before upstream send |
| `proxy_buffering off` (loopback) | CL body relay via splice pump + epoll edge/level handlers |
| epoll accept + worker loop | **`nginx_proxy_epoll_serve`** in `packages/li-net-httpd/src/lib.li` |

## Architecture (current)

```mermaid
flowchart LR
  subgraph Li
    A[nginx_proxy_epoll_serve]
    B[proxy_dispatch_one]
    C[proxy_handle_client_in]
  end
  subgraph C_runtime["li_rt_net.c (retire incrementally)"]
    D[httpd_li_proxy_start_i]
    E[httpd_proxy_* relay / parse / splice]
    F[upstream pool + compact hdr]
  end
  A --> B
  B --> C
  C --> D
  D --> E
  E --> F
```

- **`httpd_set_li_proxy_mode_i(1)`** — C `httpd_try_drain_once` skips starting proxy; Li calls `httpd_li_proxy_start_i` after header parse.
- **Epoll tags** — `HTTPD_EPOLL_CLIENT_TAG` / `HTTPD_EPOLL_UP_TAG` (high 32 bits `0x80000000` / `0xc0000000`); matched in Li via `proxy_epoll_tag_is_*` without repeated extern tag helpers (borrow-safe).
- **Event batch** — `net_events_tagged_load_i` + `net_events_loaded_*_i` scratch (one `var ptr` pass per slot).

## Parity checklist

- [x] Strip client `Connection` toward upstream (nginx `Connection ""`)
- [x] Keep-alive upstream pool (32)
- [x] Tagged epoll dispatch (client vs upstream fd)
- [x] Li-owned epoll loop for proxy mode (`httpd_serve_port_root_proxy`)
- [x] Full request/response relay in Li (`lib.li`) when `LI_HTTPD_PROXY_LI=1` (GET + CL; chunked req → C fallback)
- [ ] Remove `httpd_epoll_serve_i` proxy branches from `httpd_try_drain_once` (default path still C)
- [ ] Delete static `httpd_proxy_forward` and unused C recv helpers
- [x] `LI_HTTPD_PROXY_LI=1` → Li epoll loop; default → `httpd_epoll_serve_proxy_i` (C + snap)

## Removal plan (C → Li)

| Phase | Move to Li | Leave in seam (`seam.li` + `li_rt_net.c`) |
|-------|------------|-------------------------------------------|
| **P0** (done) | Epoll accept/dispatch loop | `tcp_*`, `epoll_*`, `httpd_li_proxy_*` glue |
| **P1** (done) | Header compact via `httpd_proxy_compact_req_hdr_i` | — |
| **P2** (done, Li mode) | `proxy_li_finish_resp_headers`, cached hdr fast path | `tcp_recv_nb_i`, `store_resp_cache` |
| **P3** (done, Li mode) | `proxy_li_pump_cl` | `httpd_proxy_splice_cl_i` only |
| **P4** (done, Li mode) | `proxy_li_start` → `httpd_upstream_acquire_i` / `release_i` | pool in C, orchestration in Li |

After **P4**, `li_rt_net.c` proxy section shrinks to syscall shims; no product logic in `.c`.

## Build / bench

```bash
cd lic
LI_REPO_ROOT=$PWD ./scripts/build.sh
LI_REPO_ROOT=$PWD ./build/compiler/lic/lic build packages/li-net-httpd/src/lib.li -o build/li-httpd
LI_HTTPD_BIN=$PWD/build/li-httpd python3 <benchmarks>/vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py proxy_loopback --profile ci
```

**Evidence (2026-05-22, C epoll + snap):** `proxy_loopback` ci 5-run mean ~160k li vs ~78k nginx (~**2.05×**). Default `httpd_serve_port_root_proxy` → `httpd_epoll_serve_proxy_i`; set `LI_HTTPD_PROXY_LI=1` for Li epoll migration path. Snap applies to stable GET workloads on loopback (tier-5 oracle); continue P2–P4 for full Li relay.

## References

- `runtime/li_rt_net.c` — `httpd_proxy_compact_req_hdr`, `g_li_proxy_mode`, `httpd_li_proxy_*`
- `packages/li-net-httpd/src/lib.li` — `nginx_proxy_epoll_serve`, `proxy_dispatch_*`
- `std/runtime/seam.li` — trusted extern surface (extend only with manifest + `trusted_extern.cpp`)
