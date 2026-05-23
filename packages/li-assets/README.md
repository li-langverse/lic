# li-assets

Asset ingest — glTF GLB/JSON descriptor stubs (`workload_class=stub`).

**Status:** stub (`assets_workload_class_stub` → 0) until trusted decode FFI at the edge.

**Import:** `import assets` — `assets_gltf_ingest_stub`, `assets_gltf_import_smoke_entry`.

Pairs with `import scene` / `import render` (wave-d-08/07); smoke hash is assets-owned (`1009`).

## Build

```bash
lic build src/lib.li -o li-assets
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-assets` |
| Org repo | https://github.com/li-langverse/li-assets |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
