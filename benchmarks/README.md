# lic/benchmarks (deprecated for org runs)

**Org benchmark workloads and harness moved to [li-langverse/benchmarks](https://github.com/li-langverse/benchmarks).**

- Workloads: `benchmarks/workloads/` in the benchmarks repo
- Driver: `harness/run_suite.py` with `LIC_ROOT` pointing at this `lic` checkout
- Tier-0 correctness smokes remain here via `li-tests` and `harness/bench.py --tier 0`

Do not add new tier-1/2 harness directories under `lic/benchmarks/tier*`.
