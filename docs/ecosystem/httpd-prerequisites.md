# li-httpd compiler prerequisites (P0)

li-httpd **M1 `.li` code** does not start until these **`lic`** gates pass. Infra in **`lis`** can proceed in parallel.

| ID | Work | Repo | Status |
|----|------|------|--------|
| P0-lean | VC + Lean on `lic build` (real discharge) | `lic` | **Partial** — AutoVC + Discharge; strict gate optional |
| P0-bytes | `std` bytes, stringview, Reader/Writer | `lic` | **Partial** — [`std/bytes/bytes.li`](../../std/bytes/bytes.li) stub; composable seam for `li-httpd` buffer types |
| P0-net | `raises Net`, trusted syscall RFC | `lic` | **Partial** — epoll static server (`httpd_epoll_serve_i`); generic GET + sendfile under doc root; tier-5 `static_small` / `keepalive_pipelining` / `static_large`; reverse proxy / LB **M1 wave 2+** |
| P0-async | async/await + epoll/kqueue | `lic` | **Partial** — parse + `raises Async` + MIR `AsyncAwait` → `li_async_*` stubs; no epoll/kqueue yet |
| P0-http | HTTP/1.1 parser proofs | `lic` | **Not started** |

**Coverage:** `std/**` = **100%**; published `li-*` = **≥80%** ([engineering-standards.md](engineering-standards.md)).

**lis:** [implementation-status](https://github.com/li-langverse/lis/blob/main/docs/implementation-status.md).
