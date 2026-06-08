# Tier-0 correctness (catalog compatibility anchor)

**Catalog id:** `tier0_stability` (PH-5b)  
**Canonical sources:** `li-tests/benchmarks/tier0_correctness/*.li`  
**Issue:** [lic#24](https://github.com/li-langverse/lic/issues/24)

## Decision (ADR)

Org benchmark catalog originally pointed at `benchmarks/tier0_correctness` on **lic**
`main`. Tier-0 correctness proofs are **verification** workloads (no perf timing);
they live under **`li-tests/`** per
[benchmarks single-repo layout](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/benchmarks-single-repo-layout.md).

**Resolution (option 2 — catalog retarget, lic anchor):**

1. **benchmarks** `catalog.toml` row `tier0_stability` → `li-tests/benchmarks/tier0_correctness`
   ([benchmarks#17](https://github.com/li-langverse/benchmarks/issues/17),
   release note `2026-05-25-lic-root-catalog-alignment`).
2. **lic** keeps this directory so legacy path probes (`GET …/benchmarks/tier0_correctness`)
   and plan audits see a stable tree; `.li` entries are symlinks to the canonical
   `li-tests` files (no duplicate sources).

## Harness

- **Build / verify:** `li-tests/run_all.sh` suite `benchmarks` (manifest rows under
  `benchmarks/tier0_correctness/`).
- **Bench driver:** `benchmarks` repo `harness/verify.py` + `bench.py --tier 0` (uses
  `LIC_ROOT/li-tests/benchmarks/tier0_correctness`).

## Tests

```bash
./scripts/build.sh
BENCHMARKS_ROOT=../benchmarks ./scripts/check-bench-harness-contract.sh
```
