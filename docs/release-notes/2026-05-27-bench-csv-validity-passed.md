# Release notes: 2026-05-27 — bench-csv-validity-passed

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (branch `cursor/bench-validity-scorecard-ce9b`)  
**PH / REQ:** PH-7e (tier-1 correctness / dashboard validity)  
**Author:** agent

---

## Summary (one sentence)

Tier-1 harness CSV `passed` now matches the same rtol/atol verify gate as `verify_benchmark_results`, and `horner_pure_li` oracle aligns with `x=1.1` in `horner_core.c`.

## Agent continuation (required)

1. Read: `benchmarks/results/README.md` (verify columns), `benchmarks/scripts/ingest/build_summary.py` (`validity_for_benchmark`).
2. Run: `cmake --build build && ./scripts/bench-verify-results.sh 1`; `cd ../benchmarks && python3 scripts/ingest/ingest-lic.sh`.
3. Then: confirm `data/latest/summary.json` has `horner_pure_li` and `reduce_sum` with `validity_status: pass`; re-run `python3 scripts/ecosystem-quality-grade.py`.
4. Blocked on: **none** for harness fix; dashboard ingest needs lic build on agent VM or nightly.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Harness CSV | `verify_csv_rows` sets `passed` from `float_close(rtol, atol)` not 1-ULP only | `benchmarks/harness/bench.py` |
| Horner spec | `HORNER_BENCH_X=1.1`; `horner_pure_li` iterative oracle (closed form overflows at 5M steps) | `benchmarks/harness/reference.py` |
| Report pick | `primary_report_for_label` for iterative + analytical exports | `benchmarks/harness/reference.py`, `bench.py` |
| Tests | `test_horner_tier1_oracle_matches_bench_x` | `benchmarks/harness/test_reference_analytical.py` |

## Not changed (scope fence)

- LLVM / MIR codegen for horner loop — **not** in this PR
- `benchmarks` ingest or `summary.json` — refresh in follow-up after bench run
- 56 failing open PRs / ecosystem scorecard `failed_prs` — **not** fixable here

## Breaking changes

None.

## Security

N/A — harness correctness only.

## Performance

N/A — no kernel timing change; expect dashboard reds cleared after re-ingest (validity gate only).

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Re-ingest after merge; nightly Linux publish should show 0 tier-1 validity reds |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Fixed
- **Tier-1 CSV validity:** `passed` column uses spec rtol/atol; `horner_pure_li` oracle matches `horner_core.c` `x=1.1` — PH-7e ([#NNN](URL)).
```
