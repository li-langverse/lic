# lis — HTTP gateway & control-plane tooling

<!-- DOC-ecosystem-lis -->

**Repository:** [`li-langverse/lis`](https://github.com/li-langverse/lis)

**lis** hosts infrastructure for the proved AI/agent **HTTP gateway** (Phase H), optional leak censorship, streaming SSE, rate limits, and **PH-DB-3** embedded **lidb** supervisor (`lis db`).

## Status

| Area | Status |
|------|--------|
| Packages, harness, docs | **Infrastructure** in place |
| **li-httpd** application `.li` | **Not started** — blocked on compiler gates; see [httpd prerequisites](httpd-prerequisites.md) |
| `lis db` / lidb embed | **Shipped** — [lis/docs/db.md](https://github.com/li-langverse/lis/blob/main/docs/db.md) |

## Quick start (contributors)

```bash
git clone https://github.com/li-langverse/lis.git
cd lis
git clone https://github.com/li-langverse/lidb.git ../lidb
pip install -e .
export LI_DATA_DIR=./.li-data
lis db start && lis db status
./scripts/ci.sh
```

## In-repo docs

| Doc | Topic |
|-----|--------|
| [docs/index.md](https://github.com/li-langverse/lis/blob/main/docs/index.md) | Overview |
| [docs/plan.md](https://github.com/li-langverse/lis/blob/main/docs/plan.md) | Full design |
| [docs/implementation-status.md](https://github.com/li-langverse/lis/blob/main/docs/implementation-status.md) | Honest milestone table |
| [docs/package-workflow.md](https://github.com/li-langverse/lis/blob/main/docs/package-workflow.md) | `li-new-package` / lip § A3 |

## Cross-links

| Doc | Role |
|-----|------|
| [li-httpd](li-httpd.md) | Composable `net.httpd` package (org mirror) |
| [httpd prerequisites](httpd-prerequisites.md) | **lic** P0 gates before M1 |
| [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | Phase H |
| [Provability gaps](../verification/provability-gaps.md) | **G-net**, **G-lean** partial |
