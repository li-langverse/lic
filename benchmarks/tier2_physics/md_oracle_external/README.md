# md_oracle_external (algo_registry id 104)

**Status:** stub — external LAMMPS/GROMACS oracle column plan (`md-r3-oracle-plan`, lic#523)

**Oracle driver:** `benchmarks/harness/md_external_oracle.py`

**Registry:** `benchmarks/competitive/md_oracle.toml` · plan `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md`

## Tiers

| Tier | Engine | Role |
|------|--------|------|
| T0 | Li `sim_scientific_oracle_checksum_md()` | Composable smoke checksum |
| T1 | Shared C (`md_core.c` on full lic checkout) | Cross-lang reference |
| T2 | LAMMPS / GROMACS micro | External oracle column (optional CI profile) |

## Gate

```bash
python3 benchmarks/harness/md_external_oracle.py --engine lammps --dry-run
./li-tests/tooling/md_external_oracle_stub.sh
```
