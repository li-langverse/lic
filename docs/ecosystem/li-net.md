# li-net — trusted TCP / `raises Net`

<!-- DOC-ecosystem-li-net -->

**Repository:** [`li-langverse/li-net`](https://github.com/li-langverse/li-net) · **Package id:** `PKG-li-net`

Org mirror of the monorepo **li-net** package: trusted networking surface for **httpd** and async I/O. Spec: [trusted-net RFC](../superpowers/specs/2026-05-16-li-trusted-net-rfc.md).

## Status

| Area | Status |
|------|--------|
| Package scaffold + CI | In place |
| Trusted syscall / codegen | **Partial** — see [httpd prerequisites](httpd-prerequisites.md) P0-net |
| Proof | **G-net** **Partial** in [provability gaps](../verification/provability-gaps.md) |

## Build

```bash
lic build src/lib.li -o li-net
```

From **lic** monorepo: `./scripts/build.sh` first.

## Cross-links

| Doc | Role |
|-----|------|
| [li-httpd](li-httpd.md) | Gateway consumer |
| [httpd prerequisites](httpd-prerequisites.md) | P0-net shipped checklist |
| [Official packages](official-packages.md) | `PKG-li-net` row |
| [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | Phase H / net |
