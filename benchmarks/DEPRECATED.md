# Deprecated: benchmark workloads moved to li-langverse/benchmarks

Perf harnesses, tier workloads, and CSV results **do not belong in `lic` anymore**.

**Canonical repo:** https://github.com/li-langverse/benchmarks

| Old (lic) | New (benchmarks) |
|-----------|------------------|
| `lic/benchmarks/harness/bench.py` | `benchmarks/scripts/run-bench.sh` → `harness/bench.py` |
| `lic/benchmarks/tier1_micro/` | `benchmarks/benchmarks/workloads/tier1_micro/` |
| `lic/benchmarks/tier2_physics/` | `benchmarks/benchmarks/workloads/tier2_physics/` |
| `lic/benchmarks/results/latest.csv` | `benchmarks/results/latest.csv` |

## Run benches from a sibling checkout

```bash
export LIC_ROOT=/path/to/lic
export BENCHMARKS_ROOT=/path/to/benchmarks
"$BENCHMARKS_ROOT/scripts/run-bench.sh" --tier 1
```

Or from lic repo:

```bash
./scripts/bench-via-benchmarks.sh --tier 1
```

## Still in lic

- **Tier-0 correctness:** `li-tests/benchmarks/tier0_correctness/` (proof smoke, not dashboard catalog)
- **Compiler CI:** `scripts/ci.sh` may invoke tier-0 via benchmarks when `BENCHMARKS_ROOT` is set

This tree will be **removed** in a follow-up PR once all CI/agents use `BENCHMARKS_ROOT`.

See benchmarks `docs/ecosystem/benchmarks-single-repo-layout.md`.
