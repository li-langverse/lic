# Release notes: 2026-06-08 — tier0_correctness catalog path (lic#24)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Issue:** [lic#24](https://github.com/li-langverse/lic/issues/24)  
**PH:** PH-5b (correctness tier / stability smoke)

## Summary

Closes the catalog gap for `tier0_stability`: adds `benchmarks/tier0_correctness/`
compatibility anchor (ADR + symlinks to `li-tests/benchmarks/tier0_correctness`) after
org catalog retarget in **benchmarks** `catalog.toml`.

## Changed

| Area | Path |
|------|------|
| ADR + symlinks | `benchmarks/tier0_correctness/` |
| Docs | `benchmarks/README.md` |

## Not changed

- Tier-0 `.li` sources (remain in `li-tests/benchmarks/tier0_correctness/`).
- **benchmarks** harness drivers (`verify.py`, `bench.py --tier 0`).

## Test plan

- `test -d benchmarks/tier0_correctness && test -f benchmarks/tier0_correctness/float_binop.li`
- With sibling **benchmarks** checkout: `./scripts/check-bench-harness-contract.sh`
