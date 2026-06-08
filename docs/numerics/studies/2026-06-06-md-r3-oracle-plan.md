# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)  
**Agent:** `code_implementer` · **Mode:** study-only (validity locked; no perf claims)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Plan:** `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md`

---

## Problem

Li tier-2 MD proves **Li ↔ shared C oracle** parity via `sim_scientific_oracle_checksum_md()`. PH-5b requires an honest **external oracle column** (LAMMPS/GROMACS) documented in harness manifests before claiming incumbent parity.

| Signal | Before | After (this slice) |
|--------|--------|-------------------|
| algo 104 `md_oracle_external` | Registry stub only | Harness path + smoke `md_external_oracle_bench.li` |
| `verticals.toml` | `oracle = cpp` | `oracle = external_binary` + driver cite |
| `registry.toml` | No LAMMPS/GROMACS rows | `lammps_lj_micro` / `gromacs_lj_micro` on watch |
| Gate script | No md-r3 check | `sim-algo-research-gates.sh` manifest + dry-run |

---

## Architecture (implemented)

| Tier | Engine | Artifact | CI default |
|------|--------|----------|------------|
| T0 | Li composable | `sim_scientific_oracle_checksum_md()` | Always |
| T1 | Shared C | `md_core.c --verify` (full lic checkout) | When tier2 present |
| T2 | LAMMPS / GROMACS | `md_external_oracle.py --dry-run` | Study gate only |

**Driver:** `benchmarks/harness/md_external_oracle.py`  
**Registry:** `benchmarks/competitive/md_oracle.toml`  
**Tier-2 path:** `benchmarks/tier2_physics/md_oracle_external/`

---

## Size scaling (oracle contract — advisory until B1)

| N | ρ (LJ) | dt | External oracle action |
|---|--------|-----|------------------------|
| 32 | 0.75 | 0.004 | Dry-run Li T0 checksum reference |
| 256 | 0.75 | 0.004 | LAMMPS micro target (input skeleton) |
| 2048 | 0.75 | 0.004 | Deferred — neighbor list parity first |

---

## Grade matrix

| Axis | Result | Notes |
|------|--------|-------|
| Validity | **pass** | Li T0 checksum band; manifest cites oracle driver |
| Performance | **document only** | No LAMMPS/GROMACS wall-time claims |
| Memory | N/A | Defer to full tier-2 checkout |
| Security | pass | No new FFI |
| Stability | **partial** | NVE drift matrix in md-r1; external T2 advisory |
| Size scaling | table attached | B1 aligns LAMMPS IC with md_core |

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md` |
| Plan | `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md` |
| Driver | `benchmarks/harness/md_external_oracle.py` |
| Gate | `./li-tests/tooling/md_external_oracle_stub.sh` |
| Smoke | `packages/li-sim-scientific/li-tests/smoke/md_external_oracle_bench.li` |
| Research gate | `SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md ./scripts/sim-algo-research-gates.sh` |

```bash
python3 benchmarks/harness/md_external_oracle.py --engine lammps --dry-run
./li-tests/tooling/md_external_oracle_stub.sh
./scripts/check-hpc-competitive.sh
```

---

## Tradeoffs

- **Locked:** validity + stability; no `threshold_ratio_cpp` weakening.
- **Shipped:** Oracle plan doc, driver stub, manifest wiring, registry honesty.
- **Deferred:** Real LAMMPS/GROMACS binary drivers (B1/B2); benchmarks#179 catalog ingest.

---

## North star fit

**Domain:** Scientific computing / molecular dynamics  
**PH ids:** PH-5b, G-math  
**Proof-before-perf:** External oracle is a validity column, not a perf shortcut.
