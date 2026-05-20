# Publish metadata — PKG-li-http

| Field | Value |
|-------|--------|
| **PKG id** | `PKG-li-http` |
| **Registry name** | `li-http` (lip, phase 8d) |
| **Maintainer** | li-langverse |
| **Repository** | https://github.com/li-langverse/li-http |
| **License** | Apache-2.0 OR MIT (SPDX) |

## Exports (v1)

HTTP/1.1 parser and routing surface (`import http`) — no sockets in this package.

## Proof / coverage tier

| Gate | Required for registry |
|------|------------------------|
| `lic build` | Yes |
| `lit test --coverage` ≥ 80% | Yes (lip 8e) |
| ed25519 manifest signature | Yes (lip 8c) |
