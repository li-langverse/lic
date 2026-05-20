# li-httpd M1 epoll hot path (C seam)

## Summary

Restores the M1 monolithic epoll server in `runtime/li_rt_net.c` (`httpd_epoll_serve_i`): level-triggered `EPOLLIN`, recv-until-`EAGAIN` per wake, prebuilt keep-alive/close response blobs, and `epoll_wait(0)` spin — tier-5 loopback benches now beat stock nginx on both `static_small` and `keepalive_pipelining`.

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` (`httpd_epoll_serve_i`, `httpd_serve_conn_epoll`, `httpd_try_drain_once`, `g_cached_blob_*`); `packages/li-net-httpd/src/lib.li` (`httpd_serve_static_blocking` → `httpd_epoll_serve_i`); `std/runtime/seam.li` (`httpd_epoll_serve_i` extern).
2. **Run:** `export LI_REPO_ROOT=/workspace/lic`; `cmake --build build -j4`; `./build/compiler/lic/lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`; `LI_HTTPD_BIN=build/li-httpd python3 vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py --profile ci` (from benchmarks checkout with vendor tree).
3. **Then:** re-ingest tier-5 CSV into **benchmarks** dashboard; port accept/drain loop back into Li when borrow checker + codegen allow without RPS regression.
4. **Blocked on:** non-Linux — `httpd_epoll_serve_i` uses Linux epoll (fallback: `httpd_blocking_serve` via `epoll_create1_i() == -1`).

## Changed

| Path | Evidence |
|------|----------|
| `runtime/li_rt_net.c` | `httpd_epoll_serve_i`, M1 recv/drain loop, prebuilt blobs, level-triggered client epoll, `epoll_wait(0)` inner spin |
| `runtime/li_rt.h` | `httpd_epoll_serve_i` declaration |
| `std/runtime/seam.li` | `extern proc httpd_epoll_serve_i` |
| `compiler/types/trusted_extern.cpp` | manifest symbol `httpd_epoll_serve_i` |
| `packages/li-net-httpd/src/lib.li` | `httpd_serve_static_blocking` calls `httpd_epoll_serve_i` when epoll available |
| `CHANGELOG.md` | Unreleased perf bullet |

## Not changed

- **lis** / **benchmarks** harness sources (`bench_http.py`, wrk flags) — same `ci` profile.
- TLS, HTTP/2, non-GET routes, path traversal beyond bench fixture.
- **Compiler** LLVM codegen / borrow checker — Li epoll loop in `lib.li` remains fallback path, not default hot path.

## Breaking

N/A — seam-only; `httpd_run_from_argv` CLI unchanged.

## Security

N/A — same trusted C seam policy as prior M0/M1: loopback static GET, syscall surface only; no new `trusted.lean` axioms.

## Performance

`bench_http.py --profile ci` (Linux loopback, ~100 B `index.html`, 2026-05-20 build):

| Scenario | nginx RPS | li RPS | li/nginx |
|----------|-----------|--------|----------|
| `static_small` (4 conn) | 85,089 | 160,027 | **1.88×** |
| `keepalive_pipelining` (16 conn, pipeline=8) | 91,303 | 319,332 | **3.50×** |

Closes prior gap (~8% serial, ~62% pipelined vs nginx) caused by one-recv-per-epoll-wake Li loop and missing prebuilt response blobs.

## Downstream

- **benchmarks:** ingest `vendor/lis-tier5/results/latest.csv` after merge.
- **li-httpd** package mirrors: sync `li-net-httpd` / `li-httpd` org repos when promoted.
