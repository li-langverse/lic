# Benchmarks moved to li-langverse/benchmarks

All harness drivers, workloads, and bench results live in the **benchmarks** repo.

```bash
export BENCHMARKS_ROOT=/path/to/benchmarks   # sibling checkout
export LIC_ROOT=/path/to/lic
"$BENCHMARKS_ROOT/scripts/run-bench.sh" --tier 1
# or from lic:
./scripts/bench-via-benchmarks.sh --tier 1
```

See `../benchmarks/docs/ecosystem/benchmarks-single-repo-layout.md`.

## Tier-0 correctness sources (lic#24)

Catalog id **`tier0_stability`** points at **`li-tests/benchmarks/tier0_correctness`** on **lic** `main` (not under this lite `benchmarks/` tree). Three `.li` smokes (`float_binop.li`, `md_energy_single_step.li`, `three_body_invariants.li`) are wired in `li-tests/manifest.toml`; harness drivers live in **benchmarks** (`verify.py`, `stability.py`, `bench.py --tier 0`).

ADR and rollout: [`docs/superpowers/plans/2026-06-07-tier0-stability-catalog-path-24.md`](../docs/superpowers/plans/2026-06-07-tier0-stability-catalog-path-24.md).
