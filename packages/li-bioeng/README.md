# li-bioeng

**PH-BIOENG** — computational biology / bioengineering LITL (Lab-in-the-Loop) and DBTL workflow stubs.

**Status:** `workload_class=stub` — stage state machine + assay score witness only; not Benchling/Rosetta/ProteinMPNN parity.

## Import

```li
import bioeng
```

## Bench

- Registry: [bioengineering.toml](../../benchmarks/competitive/bioengineering.toml)
- Composable: `li-tests/composable/import_bioeng_litl_workflow.li`
- Vertical: `bio_litl` in [verticals.toml](../../benchmarks/competitive/verticals.toml)

## Build

```bash
lic build src/lib.li -o li-bioeng
```

| Field | Value |
|-------|-------|
| Package | `PKG-li-bioeng` |
| Org repo | https://github.com/li-langverse/li-bioeng |
