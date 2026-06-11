# li-container-cri

CRI v1 API scaffold for libernetes. Depends on `li-container`, `li-container-run`, and `li-oci`; delegates lifecycle to `container.run`.

## Modules

| Module | Import | Role |
|--------|--------|------|
| `v1` | `cri.v1` | CRI v1 API version and service tags |
| `lib` | `cri` | Public selftest and lifecycle wiring |

## Build

```bash
lic build src/lib.li -o li-container-cri
```
