# Release notes: 2026-05-25 — proof-db-physics-axioms

**Status:** Ready for review | **PH:** PH-5b, PH-7e

## Summary

Seeds `proof-db/physics/` with AX-PHYS-* / LEM-PHYS-* catalogs, contract specimens, tier-2 bench + li-tests cross-refs.

## Agent continuation

1. Read `docs/verification/proof-database.md` and `proof-db/physics/*/catalog.json`.
2. Run `lic build --allow-open-vc proof-db/physics/**/*.li`.
3. Add manifest + Lean discharge when closing open lemmas.

## Not changed

trusted.lean, tier-2 C cores, contracts_verify corpus.

## Breaking / Security / Performance / Downstream

N/A.
