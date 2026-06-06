# MD external oracle (`md_oracle_external`)

**Catalog id:** `md_oracle_external` · **algo_registry:** 104 · **Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)

## Paths

| Surface | Path |
|---------|------|
| Oracle registry (lic) | `benchmarks/competitive/md_oracle.toml` |
| Gate script (lic) | `scripts/md-oracle-competitive-gates.sh` |
| Li smoke | `packages/li-sim-scientific/li-tests/smoke/md_external_oracle_bench.li` |
| Tier-2 driver (benchmarks repo) | `benchmarks/harness/md_external_oracle.py` |
| Tier-2 bench dir (benchmarks repo) | `benchmarks/tier2_physics/md_oracle_external/` |
| Plan | `docs/benchmarks/competitive-engines-plan.md` |

## Oracle driver

```
Oracle driver: benchmarks/harness/md_external_oracle.py
```

When `BENCHMARKS_ROOT` is set, run:

```bash
python3 "$BENCHMARKS_ROOT/harness/md_external_oracle.py"
```

Default CI uses the lic stub: `scripts/md_external_oracle_stub.py` (no domain binary required).

## Status

**stub** — T0 Li↔C checksum green; LAMMPS/GROMACS columns documented, not executed on default CI.
