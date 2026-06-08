# MD external oracle competitive benchmark

Compare **Li `sim_scientific_oracle_checksum_md()`** (4-particle LJ chain micro) against LAMMPS/GROMACS external oracle columns (stub honesty until B1/B2).

## Run

```bash
# From lic repo root
bash scripts/bench-ph-sci-md-oracle-competitive.sh
# CI gate (bench + JSON + registry checks)
bash scripts/ph-sci-md-oracle-competitive-gates.sh
# li-tests wiring
./li-tests/tooling/md_external_oracle_stub.sh
```

Output: `benchmarks/results/md_lennard_jones/oracle_stub.json`

## Methodology

| Field | Value |
|-------|-------|
| Li oracle | 4-particle LJ chain, spacing 1.12, rc=2.5, dt=0.004, 8 VV steps |
| Metric | Relative energy drift `|ΔE|/E` (checksum) |
| LAMMPS | **External manual oracle** — not bundled in CI |
| GROMACS | **External manual oracle** — not bundled in CI |

## License notes

- **LAMMPS** — GPL-2.0; user-installed binary only.
- **GROMACS** — LGPL-2.1; user-installed `gmx` only.
- Do **not** vendor domain binaries in CI.

## Expected parity gaps

Li micro oracle (4 particles) is intentionally smaller than tier-2 `md_lennard_jones` (N=256 FCC). External LAMMPS/GROMACS decks target the **full** workload in the external benchmarks repo. `parity_gate_pass` stays **false** until B1 aligns IC/parameters.

## Files

| Path | Role |
|------|------|
| `docs/benchmarks/competitive-engines-plan.md` | Layer B plan |
| `benchmarks/competitive/md_oracle.toml` | Registry / tier-2 gate |
| `benchmarks/harness/md_external_oracle.py` | Stub driver + manifest |
| `scripts/bench-ph-sci-md-oracle-competitive.sh` | Orchestrator |
| `scripts/ph-sci-md-oracle-competitive-gates.sh` | CI gate |
| `li-tests/tooling/md_external_oracle_stub.sh` | li-tests manifest entry |
