# Release notes: gap-close-proof-db (Phase 2b)

## Summary
Registers three proof-db math catalog lemmas and runs rebuild_lemmas report.

## Agent continuation
1. Read math-lemmas.toml and data/proof-db/latest-report.md
2. Run ./scripts/proof-db/rebuild_lemmas.sh after lic build
3. Close P-float / G-math when AutoVC aligns
4. Blocked: self-merge

## Changed
- docs/verification/proof-database/entries/math-lemmas.toml
- proof-db/math/lemmas/catalog.json
- data/proof-db/latest-report.{json,md}
- docs/verification/provability-gaps.md

## Not changed
Discharge.lean physics; LI_PROOF_DB_STRICT mandatory gate.

## Breaking / Security / Performance / Downstream
N/A.
