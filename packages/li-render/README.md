# li-render

Graphics present path — swapchain descriptor, acquire/present stubs (`workload_class=stub`).

**Status:** stub (`render_workload_class_stub` → 0) until trusted wgpu swapchain FFI and draw lists land.

**Import:** `import render` — `render_swapchain_desc_default`, `render_present_swapchain_smoke_entry`.

Pairs with `import gpu` device/LKIR smoke (wave-d-06); present hash is render-owned (`480640`).

## Build

```bash
lic build src/lib.li -o li-render
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-render` |
| Org repo | https://github.com/li-langverse/li-render |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
