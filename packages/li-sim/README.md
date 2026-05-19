# li-sim

Unified simulation step API (PH-SIM): `sim_step`, runtime profiles, SIM-2 `sim_replay_*`. Export/print lives in **`li-sim-additive`** (`import sim.additive`). `sim_step_physics` → `physics.runtime` waits on cross-package type visibility in the compiler.

Li package li-sim

## Build

```bash
lic build src/lib.li -o li-sim
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-sim` |
| Org repo | https://github.com/li-langverse/li-sim |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
