# Benchmarks moved to li-langverse/benchmarks

All harness drivers, workloads, and bench results live in the **benchmarks** repo.

**Exception — tier-0 correctness:** canonical `.li` sources are under
`li-tests/benchmarks/tier0_correctness/`; `benchmarks/tier0_correctness/` here is a
catalog compatibility anchor (symlinks + ADR — see that directory's `README.md`).

```bash
export BENCHMARKS_ROOT=/path/to/benchmarks   # sibling checkout
export LIC_ROOT=/path/to/lic
"$BENCHMARKS_ROOT/scripts/run-bench.sh" --tier 1
# or from lic:
./scripts/bench-via-benchmarks.sh --tier 1
```

See `../benchmarks/docs/ecosystem/benchmarks-single-repo-layout.md`.
