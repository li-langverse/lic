# li-demo — package scaffold example

<!-- DOC-ecosystem-li-demo -->

**Repository:** [`li-langverse/li-demo`](https://github.com/li-langverse/li-demo) · **Package id:** `PKG-li-demo`

Reference package showing **li.toml** layout, publish traceability, and agent-kit conventions. Used by **docs_maintainer** / **ci_maintainer** sandboxes and `li-new-package` workflows.

## Status

| Area | Status |
|------|--------|
| Scaffold + CI | In place |
| `documentation` URL in `li.toml` | Points here (handbook) after Pages deploy |

## Build

```bash
lic build src/lib.li -o li-demo
```

## Cross-links

| Doc | Role |
|-----|------|
| [Creating packages](../guide/creating-packages.md) | Author guide |
| [Package layout reference](../guide/package-layout-reference.md) | `li.toml` fields |
| [lip](lip.md) | Publish workflow |
| [Engineering standards](engineering-standards.md) | Traceability table |
| [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | Ecosystem PH-8 |
