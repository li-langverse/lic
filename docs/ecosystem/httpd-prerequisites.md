# li-httpd compiler prerequisites (P0)

li-httpd **M1 `.li` code** does not start until these **`lic`** gates pass. Infra in **`lis`** can proceed in parallel.

| ID | Work | Repo | Status |
|----|------|------|--------|
| P0-lean | VC + Lean on `lic build` (real discharge) | `lic` | **Partial** — AutoVC + Discharge; strict gate optional |
| P0-bytes | `std` bytes, stringview, Reader/Writer | `lic` | **Partial** — [`std/bytes/bytes.li`](../../std/bytes/bytes.li) stub |
| P0-net | `raises Net`, trusted syscall RFC | `lic` | **Partial** — effects + [`trusted.lean`](../semantics/trusted.lean) |
| P0-async | async/await + epoll/kqueue | `lic` | **Partial** — `async proc` / `await` parse + `raises Async`; no reactor codegen |
| P0-http | HTTP/1.1 parser proofs | `lic` | **Not started** |

**Coverage:** `std/**` = **100%**; published `li-*` = **≥80%** ([engineering-standards.md](engineering-standards.md)).

**lis:** [implementation-status](https://github.com/li-langverse/lis/blob/main/docs/implementation-status.md).
