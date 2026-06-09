# Publish metadata — PKG-li-std-math

| Field | Value |
|-------|--------|
| **PKG id** | `PKG-li-std-math` |
| **Registry name** | `li-std-math` (lip, phase 8d) |
| **Maintainer** | li-langverse |
| **Repository** | https://github.com/li-langverse/li-std-math |
| **License** | Apache-2.0 OR MIT (SPDX) |

## Exports (v1)

Document public `def` names and types here as the API stabilizes.

## Proof / coverage tier

| Gate | Required for registry |
|------|------------------------|
| `lic build` | Yes |
| `lit test --coverage` ≥ 80% | Yes (lip 8e) |
| ed25519 manifest signature | Yes (lip 8c) |

## Numerics reference policy

Dense LA benchmarks compare against pinned C++/BLAS references — not ad-hoc vendor drift.

| Axis | Pin |
|------|-----|
| Eigen (CI) | 3.4.1 |
| Eigen (forward) | 5.0.0 |
| C++ | C++17 |
| BLAS | OpenBLAS 0.3.x |

Canonical policy: [numerics-reference-backlog.md](../../docs/ecosystem/numerics-reference-backlog.md) · [lic#33](https://github.com/li-langverse/lic/issues/33)
