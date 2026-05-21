# Why `runtime/li_rt_net.c` lives in **lic** (not benchmarks or lis)

## Short answer

**lic** is the only repo that ships the **compiler + proof gate + trusted syscall seam**. Real sockets, epoll, and the tier-5 `li-httpd` binary are linked from **C runtime** that every `lic build` pulls in. That seam is intentionally **`li_rt_net.c`** (and friends in `runtime/`), not application `.li` in `packages/`.

## Layering

| Layer | Repo / path | Role |
|-------|-------------|------|
| **Spec + proof** | `lic` — `packages/li-net-httpd`, `packages/li-http` | `requires` / `ensures` on parse, route, serve |
| **Trusted seam** | `lic` — `runtime/li_rt_net.c`, `runtime/li_rt_httpd.c` | Syscalls, epoll, config load, match oracle — **RFC-capped C** |
| **Benchmark oracle** | `benchmarks` / `lis` — tier5_http | wrk RPS, exploit TOML — **no copy of harness into lic** |
| **Product mirror** | `li-httpd` org package (later) | Published from `lic` workspace |

## Why not only `.li`?

Per [li-httpd plan](../superpowers/plans/2026-05-16-li-httpd-plan.md) and [httpd-prerequisites](httpd-prerequisites.md):

1. **PH-2e/2f** — Production server code must pass `lic build` (VC → Lean). User `.li` owns behavior; **small C** only where the kernel has no Li model yet (sockets, epoll edge cases).
2. **Exploit suite** — Tier 5 hits the **running binary** built from `lic`. The seam is the contract boundary; nginx remains an **oracle**, not a second implementation to keep in sync in benchmarks.
3. **Single link line** — `compiler/codegen/compile.cpp` always links `li_rt.c`, `li_rt_httpd.c`, `li_rt_net.c` into `build/li-httpd`. One place to audit (`security/trusted-c-audit.toml` on `main`).

## Two files on `main` today (2026-05-21)

| File | Purpose |
|------|---------|
| `li_rt_httpd.c` | **[routes]** TOML loader, `match_route`, `lic httpd validate-config`, **one-shot** `serve_routed_once` oracle |
| `li_rt_net.c` | **Stub** fds on `main`; **full epoll server** on perf branch (`cursor/httpd-m1-perf-54aa` / `cursor/httpd-masterplan-54aa`) |

They coexist: routing/config correctness can land before the epoll production loop is rebased onto current `main`.

## What benchmarks must not do

- Do **not** vendor a second copy of `li_rt_net.c` into **benchmarks** (ingest only).
- Pin **`LIC_ROOT`** to a checkout that actually builds `build/li-httpd` with epoll when running tier-5 HTTP RPS (see benchmarks [lic-httpd-bench-compat](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/lic-httpd-bench-compat.md)).

## Agent continuation

1. Rebase **epoll** branch onto **current** `lic` `main` before merging (do not merge draft PR #84 as-is — it predates OOP/math-linalg on `main`).
2. Keep `li_rt_httpd.c` routing APIs; wire `httpd_serve_static_blocking` → `httpd_epoll_serve_i` in `packages/li-net-httpd`.
3. Re-run tier-5 suite from **benchmarks** after merge.
