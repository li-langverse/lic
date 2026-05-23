# li-chem

Quantum chemistry package — DFT single-point stub (`qm_dft` vertical; `workload_class=stub`).

**Status:** stub (`chem_workload_class_stub` → 0) until trusted ORCA/Psi4 drivers and external oracle column land.

**Import:** `import chem` — `dft_geometry_h2`, `dft_single_point_rks_stub`, smoke helpers.

**Not** gameplay `physics.chem` — see [li-chem-qm-rfc.md](../../docs/game-dev/specs/li-chem-qm-rfc.md).

Li package li-chem

## Build

```bash
lic build src/lib.li -o li-chem
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-chem` |
| Org repo | https://github.com/li-langverse/li-chem |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
