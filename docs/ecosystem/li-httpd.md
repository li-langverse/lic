# li-httpd — composable HTTP gateway package

<!-- DOC-ecosystem-li-httpd -->

**Repository:** [`li-langverse/li-httpd`](https://github.com/li-langverse/li-httpd) · **Package id:** `PKG-li-httpd`

Proved AI/agent **HTTP gateway** (Phase H). **Composable by default:** `import net.httpd` from any program; lifecycle in `src/lib.li` (see [composable-by-default](composable-by-default.md)).

## Status

| Area | Status |
|------|--------|
| **M1** application | **Not implemented** — blocked on **2e–2f** Lean gate |
| Composable API stubs | Present — aspirational samples in repo README |
| Infra / harness | Parallel work in [**lis**](lis.md) |

**Do not** claim full gateway proofs until M1 lands and [provability gaps](../verification/provability-gaps.md) rows close with evidence.

## Build (monorepo / mirror)

```bash
lic build src/lib.li -o /dev/null
lic build src/main.li -o li-httpd-demo   # optional thin demo
```

## Plans & prerequisites

| Doc | Role |
|-----|------|
| [httpd plan](../superpowers/plans/2026-05-16-li-httpd-plan.md) | Normative Phase H |
| [httpd prerequisites](httpd-prerequisites.md) | **lic** P0 compiler gates |
| [lis implementation status](https://github.com/li-langverse/lis/blob/main/docs/implementation-status.md) | Infra milestones |

## Cross-links

| Doc | Role |
|-----|------|
| [li-net](li-net.md) | Path dependency |
| [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | Phase H tracker |
| [Provability gaps](../verification/provability-gaps.md) | **G-net**, **G-lean** |
