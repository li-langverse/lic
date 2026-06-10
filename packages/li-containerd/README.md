# li-containerd

Container daemon scaffold for libernetes. Wires `li-oci`, `li-container`, `li-container-run`, and `li-container-cri` into a single runtime surface.

## Modules

| Module | Import | Role |
|--------|--------|------|
| `daemon` | `container.d.daemon` | Daemon wiring and runtime selftest |
| `lib` | `container.d` | Public version and selftest |

## Build

```bash
lic build src/lib.li -o li-containerd
```
