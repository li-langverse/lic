# li-httpd compiler prerequisites (P0)

li-httpd **M1 `.li` code** does not start until these **`lic`** gates pass. Infra in **`lis`** can proceed in parallel.

| ID | Work | Repo | Status |
|----|------|------|--------|
| P0-lean | VC + Lean on `lic build` (real discharge) | `lic` | **Partial** — AutoVC + Discharge; strict gate optional |
| P0-bytes | `std` bytes, stringview, Reader/Writer | `lic` | **Partial** — [`bytes_len`/`bytes_slice`](../../runtime/li_rt.c) link; `std_module_to_path` fix for `import std.bytes`; Reader/Writer methods deferred |
| P0-net | `raises Net`, trusted syscall RFC | `lic` | **Partial** — [`runtime/li_rt_net.c`](../../runtime/li_rt_net.c) stub fds; `httpd_serve` → `tcp_listen` in [`packages/net.httpd`](../../packages/net.httpd) |
| P0-async | async/await + epoll/kqueue | `lic` | **Partial** — parse + `raises Async` + MIR `AsyncAwait` → `li_async_*` stubs; no epoll/kqueue yet |
| P0-http | HTTP/1.1 parser proofs | `lic` | **Partial** — [`packages/http`](../../packages/http) (`parse_request`, GET probe via [`li_rt_str_byte_at`](../../runtime/li_rt.c)); full header FSM next |

**Coverage:** `std/**` = **100%**; published `li-*` = **≥80%** ([engineering-standards.md](engineering-standards.md)).

**lis:** [implementation-status](https://github.com/li-langverse/lis/blob/main/docs/implementation-status.md).
