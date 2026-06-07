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

## Social / X-ready plots

Run from the lic checkout (requires [li-langverse/benchmarks](https://github.com/li-langverse/benchmarks) harness — auto-cloned to `.cache/li-benchmarks` when missing):

```bash
./scripts/plot_shareables.sh
# → benchmarks/results/share/*.png  (16:9 dark theme; see docs/superpowers/plans/2026-05-14-plots-and-social.md)
```
