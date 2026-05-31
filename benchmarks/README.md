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
