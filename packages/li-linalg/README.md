# li-linalg

T1 numerics package — explicit linear algebra (`@` on matching shapes; no NumPy broadcast).

**Status:** stub (`linalg_workload_class_stub` → 0) until tier-1 BLAS parity.

**Import:** `import linalg` — `matmul_2x2_f32`, `matmul_2x3_f32`, smoke helpers.

Li package li-linalg

## Build

```bash
lic build src/lib.li -o li-linalg
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-linalg` |
| Org repo | https://github.com/li-langverse/li-linalg |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
