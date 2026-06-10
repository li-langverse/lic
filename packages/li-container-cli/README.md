# li-container-cli

Container CLI scaffold for libernetes. Thin wrapper over `lirun` (`container.run`).

## Modules

| Module | Import | Role |
|--------|--------|------|
| `cli` | `container.cli.cli` | argv dispatch to `lirun_run_from_argv` |
| `lib` | `container.cli` | Public version and selftest |

## Build

```bash
lic build src/main.li -o licontainer
```
