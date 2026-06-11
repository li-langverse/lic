# licontainers (deprecated)

**Deprecated** — the monolithic OCI/CRI runtime has been split into:

| Package | Import | Role |
|---------|--------|------|
| `li-oci` | `oci` | OCI spec, layout, manifest, pull/store |
| `li-container` | `container` | Bundle, state, backends |
| `li-container-run` | `container.run` | `lirun` lifecycle |
| `li-container-cri` | `cri` | CRI v1 API |
| `li-containerd` | `container.d` | Daemon scaffold |
| `li-container-cli` | `container.cli` | CLI (`licontainer`) |

This package remains as a thin compatibility shim for existing `import licontainers` callers and libernetes gate fixtures. New code should depend on the split packages directly.

Wave 3 (local CRI socket) and Wave 4 (cross-node CRI forward) stubs live under `src/cri/serve.li` and `src/runtime/` for libernetes gate selftests only.
