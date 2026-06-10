# li-oci

OCI image spec, layout, manifest/config, and pull/store (pure Li; `raises Net` only — no Container effect).

## Modules

| Module | Import | Role |
|--------|--------|------|
| `spec` | `oci.spec` | OCI spec version and media-type tags |
| `layout` | `oci.layout` | Image layout (`blobs/`, `index.json`) |
| `manifest` | `oci.manifest` | Manifest and config schema tags |
| `image` | `oci.image` | Pull/store lifecycle (`raises Net`) |

## Build

```bash
lic build src/lib.li -o li-oci
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-oci` |
| Org repo | https://github.com/li-langverse/li-oci |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
