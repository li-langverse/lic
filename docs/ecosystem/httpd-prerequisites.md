# li-httpd compiler prerequisites (P0)

li-httpd **M1 `.li` code** does not start until these **`lic`** gates pass. Infra in **`lis`** can proceed in parallel.

| ID | Work | Repo | Status |
|----|------|------|--------|
| P0-lean | VC + Lean on `lic build` (real discharge) | `lic` | **Partial (main, PR #83)** — AutoVC emit + `check-autovc-open-goals.sh`; `contracts_verify` 16/16; kernel discharge still **G-lean** partial ([proof-corpus-roadmap](../verification/proof-corpus-roadmap.md)) |
| P0-bytes | `std` bytes, stringview, Reader/Writer | `lic` | **Partial** — [`bytes_len`/`bytes_slice`](../../runtime/li_rt.c) link; `std_module_to_path` fix for `import std.bytes`; Reader/Writer methods deferred |
| P0-net | `raises Net`, trusted syscall RFC | `lic` | **Partial** — [`runtime/li_rt_net.c`](../../runtime/li_rt_net.c) stub fds; `httpd_serve` → `tcp_listen` in [`packages/li-net-httpd`](../../packages/li-net-httpd) |
| P0-async | async/await + epoll/kqueue | `lic` | **Partial** — parse + `raises Async` + MIR `AsyncAwait` → `li_async_*` stubs; no epoll/kqueue yet |
| P0-http | HTTP/1.1 parser proofs | `lic` | **Partial** — `parse_request`, `match_route`, **`lic httpd validate-config`**, `httpd_serve_once` stub; full header FSM + reactor next |

**Coverage:** `std/**` = **100%**; published `li-*` = **≥80%** ([engineering-standards.md](engineering-standards.md)).

**lis:** [implementation-status](https://github.com/li-langverse/lis/blob/main/docs/implementation-status.md).
