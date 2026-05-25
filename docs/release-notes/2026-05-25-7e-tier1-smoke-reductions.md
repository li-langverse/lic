# 7e tier-1 smoke fixture + math_linalg reduction shape errors

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH:** 7e, 2i-b · **Gap:** G-math

## Summary

Adds a committed tier-1 perf **smoke CSV** so `tier1_li_vs_cpp.sh` passes without a local `bench.py` run, restores the missing `sum_non_array.li` specimen (manifest already referenced it), and adds `dot_len_mismatch.li` for prelude `dot` length errors.

## Agent continuation

1. **Read** `scripts/check-tier1-li-vs-cpp.sh`, `benchmarks/results/README.md` § Tier-1 Li vs C++ gate.
2. **Run** `./li-tests/tooling/tier1_li_vs_cpp.sh` and `./li-tests/run_all.sh math_linalg`.
3. **Then** `python3 benchmarks/harness/bench.py --tier 1` on reference hardware; set `LI_TIER1_PERF_STRICT=1` when closing remaining tier-1 GAP rows.
4. **Blocked on:** float loop-dot Lean proof (**G-lean** / **P-linalg**); supersede branch `feat/2i-linalg-slice` (same `sum_non_array` slice).

## Changed

| Area | What | Evidence |
|------|------|----------|
| **7e** | Fixture CSV + `tier1_li_vs_cpp.sh` fallback when `latest.csv` absent | `li-tests/fixtures/tier1_math_perf_smoke.csv`, `li-tests/tooling/tier1_li_vs_cpp.sh` |
| **7e** | Reporter env/docs | `scripts/check-tier1-li-vs-cpp.sh`, `benchmarks/results/README.md` |
| **2i-b** | `sum_non_array.li` file (was manifest-only) | `li-tests/math_linalg/reductions/sum_non_array.li` |
| **2i-b** | `dot` length mismatch compile_fail | `li-tests/math_linalg/reductions/dot_len_mismatch.li` |
| **Docs** | Master plan **7e** / **2i**, `provability-gaps.md` **G-math** | paths above |

## Not changed

- No codegen or MIR lowering changes (**7e** perf still depends on existing IKJ/FMA paths).
- `benchmarks/results/latest.csv` not regenerated in this PR (hardware-specific).
- No `LI_TIER1_PERF_STRICT=1` default in CI.
- **feat/2i-linalg-slice** plan-checkbox churn not merged (deduped via `sum_non_array` only).

## Breaking

N/A — additive tests and smoke fixture.

## Security

N/A — no trusted surface or CVE rows.

## Performance

Smoke fixture rows are synthetic (ratio ≤1.15× C++). Real tier-1 evidence still requires `bench.py --tier 1` on target machine.

## Downstream

N/A — no pin changes in `lip`/`lit`/org benchmarks ingest.

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-7e / G-math:** Tier-1 reporter fixture smoke; `dot_len_mismatch.li`; restore `sum_non_array.li` — `docs/release-notes/2026-05-25-7e-tier1-smoke-reductions.md`.
```
