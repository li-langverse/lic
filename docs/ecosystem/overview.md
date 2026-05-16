# Li ecosystem overview

<!-- DOC-ecosystem-overview -->

Li ships as a **language** ([`li-langverse/li-language`](https://github.com/li-langverse/li-language)) plus **packages** you build and publish under the same org.

## Three tools

| Tool | Repo | Role | Status |
|------|------|------|--------|
| **`lic`** | [li-language](https://github.com/li-langverse/li-language) | Compile and prove your code | Available |
| **`lit`** | [**lip**](https://github.com/li-langverse/lip) | Tests and ≥80% line coverage gate | Bootstrap (phase 8e) |
| **`lip`** | [**lip**](https://github.com/li-langverse/lip) | Dependencies, lockfile, registry publish | Bootstrap (phase 8b–8d) |

Package manager and test tooling live in **[`li-langverse/lip`](https://github.com/li-langverse/lip)** (sibling repo to `li-language`).

## Creating a package today

Use the scaffold script (same layout `lip` will expect later):

```bash
./scripts/li-new-package my-lib --kind library
./scripts/li-new-package my-app --kind binary --official
```

Official / standard packages belong in **[`li-langverse`](https://github.com/li-langverse)** on GitHub. See [Creating packages](../guide/creating-packages.md) and [Governance](governance.md).

## Upstream release notifications

When **`lic`**, **`lit`**, or **`lip`** releases, dependent repos get GitHub issues / dispatch. See [upstream-notifications.md](upstream-notifications.md).

## Bootstrap lip / lit locally

```bash
git clone https://github.com/li-langverse/lip.git   # after org push
cd lip && LI_REPO=../li-language ./scripts/ci.sh
```

## Plans

| Topic | Document |
|-------|----------|
| Scaffold + `li.toml` | [Package scaffold plan](../superpowers/plans/2026-05-16-li-package-scaffold.md) |
| `lip` + `lit` | [Package manager plan](../superpowers/plans/2026-05-16-li-package-manager-lip.md) |
| Org + traceability | [Ecosystem governance](../superpowers/plans/2026-05-16-li-ecosystem-governance.md) |
| Official packages | [official-packages.md](official-packages.md) |
