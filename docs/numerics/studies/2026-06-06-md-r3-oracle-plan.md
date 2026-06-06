# MD external oracle column plan — SOTA survey + gate contract (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)  
**Agent:** `code_implementer` · **Mode:** study-only (validity locked; external oracle stub)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Plan:** `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md` · `docs/benchmarks/competitive-engines-plan.md`

---

## Problem

Li tier-2 MD proves **Li ↔ shared C oracle** via `sim_scientific_oracle_checksum_md()`. PH-5b honesty also requires documenting **LAMMPS/GROMACS** as external validity columns (algo_registry **104** `md_oracle_external`) without claiming parity from stub rows.

| Signal | Before md-r3 | After md-r3 (this study) |
|--------|--------------|---------------------------|
| `md_oracle.toml` | Missing on main | Pins + drivers + gate script |
| `verticals.toml` | `oracle = cpp` only narrative | Notes + Layer B csv_lang plan |
| `li-tests` manifest | No external oracle citation | `md_external_oracle_bench.li` |
| Research loop | `plan_pending = md-r3-oracle-plan` | Gate + study complete |

---

## Learned from

1. **LAMMPS run docs** — micro NVE LJ decks; fixed seed; minimum-image cutoff.  
   https://docs.lammps.org/Commands_run.html

2. **GROMACS algorithms** — neighbor search + list buffer; validity axis is energy drift vs list update.  
   https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html

3. **md-r0 SOTA survey** — algo 104 mapped to LAMMPS/GROMACS micro; honesty gap explicit.  
   `docs/numerics/studies/2026-05-27-md-r0-sota-survey.md`

4. **Sim output contract** — `md_external_oracle.py` named as harness target; JSON summary schema.  
   `docs/ecosystem/sim-output-contract.md`

---

## Size scaling (oracle workload targets)

| N | steps | dt | Expected use | Li / stub action |
|---|-------|-----|--------------|------------------|
| 32 | 1_000 | 0.004 | Fast sanity (B1 deck bring-up) | Document only |
| 256 | 10_000 | 0.004 | Canonical tier-2 contract | T0 checksum smoke |
| 2048 | 10_000 | 0.004 | Post-neighbor PH-7e target | Defer until 105 parity |

---

## Gate script reference (shipped)

```bash
./scripts/md-oracle-competitive-gates.sh
./li-tests/tooling/md_external_oracle_stub.sh
SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh
```

Harness manifest:

```bash
grep -E 'md_external_oracle|md_oracle_external' \
  packages/li-sim-scientific/li-tests/manifest.toml li-tests/manifest.toml \
  benchmarks/competitive/README-md-oracle.md
```

---

## Implementation path

1. **B0 (this PR):** `md_oracle.toml`, competitive plan, lic stub manifest, algo 104 smoke.
2. **B1:** LAMMPS micro in benchmarks repo — `lang=lammps` validity row.
3. **B2:** GROMACS `gmx mdrun` — `lang=gromacs` validity row.
4. **B3:** Catalog ingest benchmarks#179 for `md_oracle_external`.

**Do not:** weaken tier-0 thresholds; ship perf claims from stub rows.

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | **pass (plan+stub)** | new | T0 Li smoke; external oracle documented stub |
| Performance | **document only** | — | No LAMMPS/GROMACS wall-time claims |
| Memory | N/A | — | Defer to sim-bench-memory post-neighbor |
| Security | pass | — | No new FFI; stub only |
| Stability | **pass (T0)** | — | Existing md oracle checksum bounds |
| Size scaling | table attached | — | N=32/256/2048 targets for B1/B2 |

---

## Tradeoffs

- **Locked:** validity + stability (T0 checksum); no dashboard threshold relaxation.
- **Improved:** algo 104 harness path cited in li-tests; gate script wired; registry honesty.
- **Regressed:** none (study-only + stub).
- **Not approved:** default CI requiring LAMMPS/GROMACS binaries.

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md` |
| Plan | `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md` |
| Registry | `benchmarks/competitive/md_oracle.toml` |
| Gate | `scripts/md-oracle-competitive-gates.sh` (exit 0) |
| Smoke | `packages/li-sim-scientific/li-tests/smoke/md_external_oracle_bench.li` |
| li-tests | `./li-tests/tooling/md_external_oracle_stub.sh` |
