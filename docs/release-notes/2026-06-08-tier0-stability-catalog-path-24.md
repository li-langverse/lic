# Release notes: 2026-06-08 — tier0_stability catalog path (lic#24)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Issue:** [#24](https://github.com/li-langverse/lic/issues/24)  
**PH / REQ:** PH-5b, REQ-BENCH-CATALOG-1, REQ-BENCH-TIER0-1

---

## Summary

Document the plan-approved ADR for **tier0_stability**: canonical workload path is `li-tests/benchmarks/tier0_correctness` on **lic**; harness drivers remain in **benchmarks**. Closes the catalog gap without duplicating tier-0 drivers under `lic/benchmarks/`.

## Changed

| Area | What |
|------|------|
| Plan | `docs/superpowers/plans/2026-06-07-tier0-stability-catalog-path-24.md` — ADR Option 2 (catalog retarget) |
| README | `benchmarks/README.md` — cross-link to canonical tier-0 sources |

## Verification

- `GET /repos/li-langverse/lic/contents/li-tests/benchmarks/tier0_correctness` → 200 (three `.li` files)
- `LIC_ROOT=$PWD python3 ../benchmarks/scripts/plan-completion-audit.py` — **`tier0_stability` absent** from `catalog_gaps`
- Catalog on **benchmarks** `main`: `path = "li-tests/benchmarks/tier0_correctness"`

## north_star_fit

Correctness/stability smoke · **PH-5b** · proof-before-perf (tier-0 verify before tier 1+ timing).
