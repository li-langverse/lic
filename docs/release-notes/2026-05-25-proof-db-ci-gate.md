# Release notes: proof-db CI release gate
## Summary
Compiler release gate: export Lean theorems vs `proof-db/baseline.json`; advisory CI by default.
## Agent continuation
1. Read `docs/verification/proof-database.md`
2. Run `./scripts/check-proof-db-release.sh` after greeter build
3. Refresh baseline when intentionally adding proofs
4. Blocked on: org GHA `LI_PROOF_DB_STRICT=1` policy
