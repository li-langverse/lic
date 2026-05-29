# HTTP gateway (`li-httpd`)

**Repository:** [`li-langverse/li-httpd`](https://github.com/li-langverse/li-httpd) · **PKG id:** `PKG-li-httpd`

AI/agent gateway: TOML config, streaming, rate limits, load balancing, auto-TLS. Nginx is a **bench/CVE oracle**, not a config clone target.

## Status

| Milestone | Status |
|-----------|--------|
| M1 core (routes, static, LB, limits) | **Done** in monorepo harness |
| M1.5 bearer auth, leak censor | **Partial** — see [httpd plan](../superpowers/plans/2026-05-16-li-httpd-plan.md) |
| M2 TLS/H2 | **Partial** |
| Lean proof surface | **G-net** [Partial](../verification/provability-gaps.md#g-net) |

## Quick links

| Topic | Doc |
|-------|-----|
| Full plan + todos | [2026-05-16-li-httpd-plan.md](../superpowers/plans/2026-05-16-li-httpd-plan.md) |
| Prerequisites (bytes, Net effect) | [HTTPd prerequisites](httpd-prerequisites.md) |
| Package mirror | [lis handbook](lis.md) |
| Tier-5 exploit harness | [Webserver security](../testing/webserver-security.md) |

## Release notes

User-facing gateway changes: `CHANGELOG.md` + `docs/release-notes/` in **li-httpd** per [engineering standards](engineering-standards.md).
