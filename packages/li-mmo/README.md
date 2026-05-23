# li-mmo

**PH-MMO** — MMORPG shard tick + zone handoff stubs for the `mmo` Studio profile.

**Status:** `workload_class=stub` — shard state machine + PH-MMO phase witness only; not Photon/Spatial/custom-shard parity.

## Import

```li
import mmo
```

## Bench

- Registry: [mmorpg.toml](../../benchmarks/competitive/mmorpg.toml)
- Composable: `li-tests/composable/import_mmo_shard.li`
- Vertical: `mmo_shard` in [verticals.toml](../../benchmarks/competitive/verticals.toml)

## Build

```bash
lic build src/lib.li -o li-mmo
```

| Field | Value |
|-------|-------|
| Package | `PKG-li-mmo` |
| Org repo | https://github.com/li-langverse/li-mmo |
