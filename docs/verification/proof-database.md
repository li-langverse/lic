# Proof database index

**Audience:** agents extending formal verification beyond `contracts_verify/` — science benchmarks, physics packages, and tier-2 bench oracles.

**Hub:** [proof-database/README.md](proof-database/README.md) (discrepancy taxonomy, tier-2 paths)  
**Related:** [Proof corpus roadmap](proof-corpus-roadmap.md) · [Provability gaps](provability-gaps.md) · [Verification overview](overview.md) · [`proof-db/physics/`](../../proof-db/physics/)

**Slice pin:** `last_verified_lic_commit = a9542bfc` · **Gap:** **G-physics**

## Physics axioms (`P-AX-*`)

| ID | Statement (short) | `proof_status` | `gap_kind` | Lean / specimen | Bench / li-tests |
|----|-------------------|----------------|------------|-----------------|------------------|
| **P-AX-MECH-001** | Newton I (inertia) | open | modeling_gap | `newton_laws.li` | tier2: three_body, nbody_gravity, md_lennard_jones |
| **P-AX-MECH-002** | Newton II (F = m a) | open | proof_gap | `force_equals_mass_accel_stub` | same tier2 trio |
| **P-AX-MECH-003** | Newton III (action–reaction) | open | modeling_gap | `newton_laws.li` | same tier2 trio |
| **P-AX-CONS-001** | Energy drift window | open | modeling_gap | `conservation.li` | `md_energy_single_step.li`; tier2 MD |
| **P-AX-CONS-002** | Momentum invariant | open | modeling_gap | `conservation.li` | `three_body_invariants.li`; tier2 three_body, nbody |
| **P-AX-DIM-001** | Dimensional homogeneity | open | proof_gap | `dimensional_homogeneity_placeholder` | — |
| **P-AX-DIM-002** | SI coherence | open | proof_gap | `dimensional_homogeneity_placeholder` | — |

Source: [entries/physics-mechanics.toml](proof-database/entries/physics-mechanics.toml), [physics-conservation.toml](proof-database/entries/physics-conservation.toml), [physics-dimensions.toml](proof-database/entries/physics-dimensions.toml).

## Physics lemmas (`P-LM-*`)

| ID | Statement (short) | `proof_status` | `gap_kind` | `lean_thm` | Notes |
|----|-------------------|----------------|------------|------------|-------|
| **P-LM-ENERGY-001** | T = ½ m v² | proved | none | `kinetic_energy_def_consistent` | `Discharge.lean` |
| **P-LM-MOM-001** | p = m v | proved | none | `linear_momentum_linear_stub` | `Discharge.lean` |
| **P-LM-CONS-001** | Composed invariants | open | modeling_gap | — | `energy_drift_bound.li` |

Source: [entries/physics-lemmas.toml](proof-database/entries/physics-lemmas.toml).

## Tier-2 bench cross-refs

- **Catalog:** `li-langverse/benchmarks` `catalog.toml` (`md_lennard_jones`, `three_body`, `nbody_gravity`, …)
- **Harness:** `benchmarks/harness/bench.py` → `TIER2_BENCHES`
- **Paths:** `benchmarks/tier2_physics/<id>/`

## li-tests smokes (physics slice)

- `li-tests/benchmarks/tier0_correctness/md_energy_single_step.li`
- `li-tests/benchmarks/tier0_correctness/three_body_invariants.li`
- `li-tests/physics/profile_defaults.li`, `three_body_mini.li`

## Agent workflow

1. Read `proof-database/entries/physics-*.toml` and [README](proof-database/README.md).
2. Edit linked `proof-db/physics/*.li` specimens; keep `bench_refs` / `li_tests` in TOML in sync.
3. Run `python3 scripts/proof-db/proof-db.py verify-slice` (when CLI present on branch).
4. Scalar lemmas: extend `docs/semantics/Discharge.lean`; refresh `last_verified_lic_commit` on closure.
5. Update this index and [proof-corpus-roadmap.md](proof-corpus-roadmap.md) / [provability-gaps.md](provability-gaps.md).

## Honesty

- **modeling_gap** rows do not claim tier-2 wall-time oracles are kernel-proved.
- **proof_gap** rows have discharge stubs but lack full Lean/`contracts_verify` closure.
- **`proved`** lemma rows require a named `lean_thm` in `Li.Discharge` (see **P-LM-ENERGY-001**, **P-LM-MOM-001**).
