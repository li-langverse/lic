# External MD oracle driver (LAMMPS / GROMACS columns)

**Status:** B0 stub (2026-05-23) — records native `md_core.c` reference drift; no domain binary required in CI.

**Plan:** [competitive-engines-plan.md](../../../../docs/benchmarks/competitive-engines-plan.md)  
**Registry:** [md_oracle.toml](../../../competitive/md_oracle.toml) · [verticals.toml](../../../competitive/verticals.toml) `md_lennard_jones`

---

## Purpose

Tier-2 `md_lennard_jones` compares **language runtimes** (cpp, rust, julia, li) via shared `md_core.c`. Layer B adds **domain tool validity columns** (`lang=lammps`, `lang=gromacs` in future `latest.csv`) — external binaries as oracles, not perf competitors until workloads match.

**Honesty:** `workload_class=stub` in `verticals.toml` until B1/B2 green validity rows. Do **not** claim GROMACS/LAMMPS parity from stub output.

---

## Files

| File | Role |
|------|------|
| `run_oracle_stub.sh` | CI entry — delegates to `benchmarks/harness/md_external_oracle.py` |
| `lammps_mdlj.lammps` | LAMMPS input skeleton (B1; not executed in stub mode) |
| `gromacs_mdlj.mdp` | GROMACS MDP skeleton (B2; not executed in stub mode) |
| `pins.env.example` | Pinned tool versions — copy to `pins.env` (gitignored) for local B1/B2 |

---

## Stub driver flow (B0)

1. Build native `md_main.c` + `md_core.c`, run `--verify`, capture relative energy drift.
2. Load oracle ids from `md_oracle.toml` (`lammps_lj_micro`, `gromacs_lj_micro`).
3. Write manifest `benchmarks/results/md_lennard_jones/oracle_stub.json` with `mode=stub_ok`.
4. If `LI_MD_ORACLE_LAMMPS=1` (or `LI_MD_ORACLE_GROMACS=1`) and binary on PATH → exit 2 (reserved for B1/B2).

```bash
./benchmarks/tier2_physics/md_lennard_jones/external/run_oracle_stub.sh
./li-tests/tooling/md_external_oracle_stub.sh
```

---

## LAMMPS / GROMACS column plan (`latest.csv`)

| Phase | `csv_lang` | Oracle id | `status` | Exit evidence |
|-------|------------|-----------|----------|---------------|
| **B0** | `lammps`, `gromacs` | `lammps_lj_micro`, `gromacs_lj_micro` | `stub` | `md_external_oracle_stub.sh` green |
| **B1** | `lammps` | `lammps_lj_micro` | `active` | Deck matches FCC+MB IC; drift ±ε vs native |
| **B2** | `gromacs` | `gromacs_lj_micro` | `active` | `gmx mdrun` on pinned 2024.x |

Registry rows: `benchmarks/competitive/registry.toml` (`track=watch`) + `md_oracle.toml` (`oracle=external_binary`).

**Workload contract** (canonical): N=256, steps=10_000, dt=0.004, rc=2.5, box=10, LJ 12-6, NVE — see `../params.toml` and `../common/md_core.h`.

**Validity metric:** `|ΔE|/E` after mapping tool output to reduced units (same definition as `md_main --verify`).

---

## Local real-driver attempts (B1+)

```bash
cp pins.env.example pins.env   # edit paths
# source pins.env
export LI_MD_ORACLE_LAMMPS=1   # or LI_MD_ORACLE_GROMACS=1
./run_oracle_stub.sh           # exit 2 until driver implemented
```

Pins must match `md_oracle.toml` (`LAMMPS_PINNED_VERSION`, `GROMACS_PINNED_VERSION`).

---

## Agent rules

- Run `./scripts/bench-verify-results.sh 2` when touching `md_core.c` or oracle mapping.
- Update `last_reviewed` in `md_oracle.toml` on quarterly SOTA review.
- Cite `verticals.toml` `md_lennard_jones` + `workload_class=stub` in PRs — no “faster than GROMACS” from stub.
