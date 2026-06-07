# Publish metadata — PKG-li-demo

| Field | Value |
|-------|--------|
| **PKG id** | `PKG-li-demo` |
| **Registry name** | `li-demo` (lip, phase 8d) |
| **Maintainer** | li-langverse |
| **Repository** | https://github.com/li-langverse/li-demo |
| **License** | Apache-2.0 OR MIT (SPDX) |

## Exports (v1)

Document public `def` names and types here as the API stabilizes.

## Proof / coverage tier

| Gate | Required for registry |
|------|------------------------|
| `lic build` | Yes |
| `lit test --coverage` ≥ 80% | Yes (lip 8e) |
| ed25519 manifest signature | Yes (lip 8c) |

## Traceability

| Type | ID | Artifact |
|------|-----|----------|
| Package | `PKG-li-demo` | This repository |
| Phase | PH-Pkg | [Package scaffold](../../docs/superpowers/plans/2026-05-16-li-package-scaffold.md) |
| Test | T-PKG-li-demo-smoke | `li-tests/smoke/builds.li` |

Full RTM: [`docs/traceability.md`](docs/traceability.md).
