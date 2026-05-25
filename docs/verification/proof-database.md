# Proof database

**Related:** [proof-db/physics/](../../proof-db/physics/) · [proof-corpus-roadmap](proof-corpus-roadmap.md)

## AX-PHYS-* / LEM-PHYS-* (classical physics seed)

| ID | Title | Status |
|----|-------|--------|
| AX-PHYS-001 | Newton first law | target |
| AX-PHYS-002 | Newton second law (F = m a) | target |
| AX-PHYS-003 | Newton third law | target |
| AX-PHYS-004 | Energy conservation (isolated) | target |
| AX-PHYS-005 | Linear momentum conservation | target |
| LEM-PHYS-001 | Energy drift bound | open |
| LEM-PHYS-002 | Momentum invariant | open |
| LEM-PHYS-003 | Force reciprocity | open |
| LEM-PHYS-004 | NumericalTargets budgets | proved |

Catalogs: `proof-db/physics/axioms/catalog.json`, `proof-db/physics/lemmas/catalog.json`.

## Tier-2 bench

`benchmarks/harness/bench.py` TIER2_BENCHES; **benchmarks** repo `catalog.toml` (`md_lennard_jones`, `three_body`, `nbody_gravity`, …).

## li-tests smokes

- `li-tests/benchmarks/tier0_correctness/md_energy_single_step.li`
- `li-tests/benchmarks/tier0_correctness/three_body_invariants.li`
- `li-tests/physics/profile_defaults.li`, `three_body_mini.li`
